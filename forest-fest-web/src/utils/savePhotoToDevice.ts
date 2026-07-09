import { blobToJpegFile, buildLogPhotoFilename } from './festivalLogPhotoFiles'

export function canSavePhotoToDevice(blob: Blob): boolean {
  const file = blobToJpegFile(blob, 'forest-fest.jpg')
  return typeof navigator.share === 'function' && Boolean(navigator.canShare?.({ files: [file] }))
}

/**
 * Save a photo to the device. On iOS Safari this opens the system share sheet —
 * there is no web API for silent camera-roll writes. Desktop/Android may download instead.
 */
export async function savePhotoToDevice(
  blob: Blob,
  artistName: string,
): Promise<'shared' | 'downloaded' | 'unsupported'> {
  const file = blobToJpegFile(blob, buildLogPhotoFilename(artistName))

  if (typeof navigator.share === 'function' && navigator.canShare?.({ files: [file] })) {
    try {
      await navigator.share({
        files: [file],
        title: 'Forest Fest moment',
      })
      return 'shared'
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') {
        return 'shared'
      }
      throw err
    }
  }

  const url = URL.createObjectURL(blob)
  try {
    const link = document.createElement('a')
    link.href = url
    link.download = file.name
    link.rel = 'noopener'
    document.body.appendChild(link)
    link.click()
    link.remove()
    return 'downloaded'
  } finally {
    URL.revokeObjectURL(url)
  }
}
