import { GENERAL_FROLLOCKS_ID } from '../types/festivalLog'

const MAX_DIMENSION = 2048
const JPEG_QUALITY = 0.92

interface LoadedImage {
  source: CanvasImageSource
  width: number
  height: number
  cleanup?: () => void
}

async function loadOrientedImage(blob: Blob): Promise<LoadedImage> {
  if (typeof createImageBitmap === 'function') {
    try {
      const bitmap = await createImageBitmap(blob, { imageOrientation: 'from-image' })
      return {
        source: bitmap,
        width: bitmap.width,
        height: bitmap.height,
        cleanup: () => bitmap.close(),
      }
    } catch {
      try {
        const bitmap = await createImageBitmap(blob)
        return {
          source: bitmap,
          width: bitmap.width,
          height: bitmap.height,
          cleanup: () => bitmap.close(),
        }
      } catch {
        // Fall through to Image element.
      }
    }
  }

  const url = URL.createObjectURL(blob)
  try {
    const image = new Image()
    image.src = url
    await image.decode()
    return {
      source: image,
      width: image.naturalWidth,
      height: image.naturalHeight,
      cleanup: () => URL.revokeObjectURL(url),
    }
  } catch (err) {
    URL.revokeObjectURL(url)
    throw err
  }
}

function fitDimensions(width: number, height: number): { width: number; height: number } {
  if (!width || !height) {
    throw new Error('Invalid image dimensions')
  }

  const longest = Math.max(width, height)
  if (longest <= MAX_DIMENSION) return { width, height }

  const scale = MAX_DIMENSION / longest
  return {
    width: Math.round(width * scale),
    height: Math.round(height * scale),
  }
}

function wrapLines(ctx: CanvasRenderingContext2D, text: string, maxWidth: number): string[] {
  const words = text.trim().split(/\s+/).filter(Boolean)
  if (words.length === 0) return [text]

  const lines: string[] = []
  let current = ''

  const pushWordByCharacter = (word: string) => {
    let chunk = ''
    for (const char of word) {
      const next = `${chunk}${char}`
      if (ctx.measureText(next).width <= maxWidth) {
        chunk = next
      } else {
        if (chunk) lines.push(chunk)
        chunk = char
      }
    }
    return chunk
  }

  for (const word of words) {
    const candidate = current ? `${current} ${word}` : word
    if (ctx.measureText(candidate).width <= maxWidth) {
      current = candidate
      continue
    }

    if (current) lines.push(current)

    if (ctx.measureText(word).width > maxWidth) {
      current = pushWordByCharacter(word)
    } else {
      current = word
    }
  }

  if (current) lines.push(current)
  return lines
}

function canvasToJpegBlob(canvas: HTMLCanvasElement): Promise<Blob> {
  return new Promise((resolve, reject) => {
    if (typeof canvas.toBlob === 'function') {
      canvas.toBlob(
        (blob) => {
          if (blob) {
            resolve(blob)
            return
          }
          fallbackToDataUrl()
        },
        'image/jpeg',
        JPEG_QUALITY,
      )
      return
    }

    fallbackToDataUrl()

    function fallbackToDataUrl() {
      try {
        const dataUrl = canvas.toDataURL('image/jpeg', JPEG_QUALITY)
        const [header, base64] = dataUrl.split(',')
        const mime = header.match(/:(.*?);/)?.[1] ?? 'image/jpeg'
        const binary = atob(base64)
        const bytes = new Uint8Array(binary.length)
        for (let i = 0; i < binary.length; i += 1) {
          bytes[i] = binary.charCodeAt(i)
        }
        resolve(new Blob([bytes], { type: mime }))
      } catch (error) {
        reject(error instanceof Error ? error : new Error('Failed to brand photo'))
      }
    }
  })
}

function drawBrandOverlay(
  ctx: CanvasRenderingContext2D,
  width: number,
  height: number,
  label: string,
): void {
  const paddingX = Math.max(18, Math.round(width * 0.04))
  const paddingY = Math.max(16, Math.round(height * 0.02))
  const centerGap = Math.max(10, Math.round(width * 0.02))
  const labelSize = Math.max(20, Math.round(width * 0.048))
  const brandSize = Math.max(12, Math.round(labelSize * 0.52))
  const brandLineHeight = Math.round(brandSize * 1.1)
  const artistLineHeight = Math.round(labelSize * 1.12)
  const halfColumnWidth = width * 0.5 - paddingX - centerGap

  ctx.font = `700 ${labelSize}px system-ui, -apple-system, BlinkMacSystemFont, sans-serif`
  const artistLines = wrapLines(ctx, label.toUpperCase(), halfColumnWidth)

  ctx.font = `600 ${brandSize}px system-ui, -apple-system, BlinkMacSystemFont, sans-serif`
  const brandLines = wrapLines(ctx, 'FOREST FEST 2026', halfColumnWidth)

  const contentHeight = Math.max(
    brandLines.length * brandLineHeight,
    artistLines.length * artistLineHeight,
  )
  const barHeight = Math.max(72, paddingY * 2 + contentHeight)
  const barTop = height - barHeight

  const gradient = ctx.createLinearGradient(0, barTop, 0, height)
  gradient.addColorStop(0, 'rgba(8, 24, 14, 0.15)')
  gradient.addColorStop(0.25, 'rgba(8, 24, 14, 0.82)')
  gradient.addColorStop(1, 'rgba(8, 24, 14, 0.96)')
  ctx.fillStyle = gradient
  ctx.fillRect(0, barTop, width, barHeight)

  ctx.textBaseline = 'bottom'
  ctx.shadowColor = 'rgba(0, 0, 0, 0.45)'
  ctx.shadowBlur = Math.max(4, Math.round(labelSize * 0.18))

  ctx.textAlign = 'left'
  ctx.fillStyle = 'rgba(255, 255, 255, 0.9)'
  ctx.font = `600 ${brandSize}px system-ui, -apple-system, BlinkMacSystemFont, sans-serif`
  brandLines.forEach((line, index) => {
    const lineFromBottom = brandLines.length - 1 - index
    const y = height - paddingY - lineFromBottom * brandLineHeight
    ctx.fillText(line, paddingX, y)
  })

  ctx.textAlign = 'right'
  ctx.fillStyle = '#ffffff'
  ctx.font = `700 ${labelSize}px system-ui, -apple-system, BlinkMacSystemFont, sans-serif`
  artistLines.forEach((line, index) => {
    const y = height - paddingY - index * artistLineHeight
    ctx.fillText(line, width - paddingX, y)
  })

  ctx.textAlign = 'left'
  ctx.shadowBlur = 0
}

export async function brandFestivalPhoto(blob: Blob, label: string): Promise<Blob> {
  const loaded = await loadOrientedImage(blob)
  const fitted = fitDimensions(loaded.width, loaded.height)

  const canvas = document.createElement('canvas')
  canvas.width = fitted.width
  canvas.height = fitted.height
  const ctx = canvas.getContext('2d')
  if (!ctx) throw new Error('Could not brand photo')

  try {
    ctx.drawImage(loaded.source, 0, 0, fitted.width, fitted.height)
    drawBrandOverlay(ctx, fitted.width, fitted.height, label)
    return await canvasToJpegBlob(canvas)
  } finally {
    loaded.cleanup?.()
  }
}

export function getSelectedArtistLabel(
  selectedArtistId: string,
  artists: { id: string; name: string }[],
  generalLabel: string,
): string {
  if (selectedArtistId === GENERAL_FROLLOCKS_ID) return generalLabel
  return artists.find((artist) => artist.id === selectedArtistId)?.name ?? generalLabel
}
