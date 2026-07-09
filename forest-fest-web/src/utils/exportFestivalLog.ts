import JSZip from 'jszip'
import type { FestivalLogEntryWithPhoto } from '../types/festivalLog'
import { blobToJpegFile, buildLogPhotoFilename } from './festivalLogPhotoFiles'

export type ExportAllResult = 'shared' | 'zip'

async function entriesToFiles(entries: FestivalLogEntryWithPhoto[]): Promise<File[]> {
  const files: File[] = []

  for (const entry of entries) {
    const response = await fetch(entry.photoUrl)
    const blob = await response.blob()
    const filename = buildLogPhotoFilename(entry.artistName, entry.createdAt)
    files.push(blobToJpegFile(blob, filename))
  }

  return files
}

function canShareFiles(files: File[]): boolean {
  return typeof navigator.share === 'function' && Boolean(navigator.canShare?.({ files }))
}

async function shareFiles(files: File[]): Promise<void> {
  await navigator.share({
    files,
    title: 'Forest Fest Log',
    text: `${files.length} festival moment${files.length === 1 ? '' : 's'}`,
  })
}

async function downloadZip(files: File[]): Promise<void> {
  const zip = new JSZip()
  const usedNames = new Set<string>()

  for (const file of files) {
    let name = file.name
    let duplicate = 1
    while (usedNames.has(name)) {
      duplicate += 1
      name = file.name.replace(/\.jpg$/i, `-${duplicate}.jpg`)
    }
    usedNames.add(name)
    zip.file(name, file)
  }

  const blob = await zip.generateAsync({ type: 'blob' })
  const url = URL.createObjectURL(blob)

  try {
    const link = document.createElement('a')
    link.href = url
    link.download = 'forest-fest-log.zip'
    link.rel = 'noopener'
    document.body.appendChild(link)
    link.click()
    link.remove()
  } finally {
    URL.revokeObjectURL(url)
  }
}

/**
 * Export every branded log photo. Tries multi-file share first (best on iPhone),
 * then falls back to a ZIP download.
 */
export async function exportAllFestivalLogPhotos(
  entries: FestivalLogEntryWithPhoto[],
): Promise<ExportAllResult> {
  if (entries.length === 0) {
    throw new Error('No photos to export')
  }

  const files = await entriesToFiles(entries)

  if (canShareFiles(files)) {
    try {
      await shareFiles(files)
      return 'shared'
    } catch (err) {
      if (err instanceof DOMException && err.name === 'AbortError') {
        throw err
      }
    }
  }

  await downloadZip(files)
  return 'zip'
}
