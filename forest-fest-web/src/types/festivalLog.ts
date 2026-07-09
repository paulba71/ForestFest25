export const GENERAL_FROLLOCKS_ID = 'general-frollicks'
export const GENERAL_FROLLOCKS_LABEL = 'General frolics'

export interface FestivalLogEntry {
  id: string
  createdAt: string
  artistId: string | null
  artistName: string
  caption: string
  photoId: string
}

export interface FestivalLogEntryWithPhoto extends FestivalLogEntry {
  photoUrl: string
}
