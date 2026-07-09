export function buildLogPhotoFilename(artistName: string, createdAt?: string): string {
  const slug = artistName
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
  const stamp = (createdAt ?? new Date().toISOString()).replace(/[:.]/g, '-')
  return `forest-fest-${slug || 'moment'}-${stamp}.jpg`
}

export function blobToJpegFile(blob: Blob, filename: string): File {
  const type = blob.type.startsWith('image/') ? blob.type : 'image/jpeg'
  return new File([blob], filename, { type })
}
