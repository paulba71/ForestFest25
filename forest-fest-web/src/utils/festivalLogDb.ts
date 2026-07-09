import type { FestivalLogEntry } from '../types/festivalLog'

const DB_NAME = 'forest-fest-log-v1'
const DB_VERSION = 1
const ENTRIES_STORE = 'entries'
const PHOTOS_STORE = 'photos'

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, DB_VERSION)
    request.onerror = () => reject(request.error)
    request.onsuccess = () => resolve(request.result)
    request.onupgradeneeded = () => {
      const db = request.result
      if (!db.objectStoreNames.contains(ENTRIES_STORE)) {
        db.createObjectStore(ENTRIES_STORE, { keyPath: 'id' })
      }
      if (!db.objectStoreNames.contains(PHOTOS_STORE)) {
        db.createObjectStore(PHOTOS_STORE, { keyPath: 'id' })
      }
    }
  })
}

function tx<T>(
  storeName: string,
  mode: IDBTransactionMode,
  fn: (store: IDBObjectStore) => IDBRequest<T>,
): Promise<T> {
  return openDb().then(
    (db) =>
      new Promise<T>((resolve, reject) => {
        const transaction = db.transaction(storeName, mode)
        const store = transaction.objectStore(storeName)
        const request = fn(store)
        request.onerror = () => reject(request.error)
        request.onsuccess = () => resolve(request.result as T)
      }),
  )
}

export async function saveLogPhoto(id: string, blob: Blob): Promise<void> {
  await tx(PHOTOS_STORE, 'readwrite', (store) => store.put({ id, blob }))
}

export async function getLogPhoto(id: string): Promise<Blob | null> {
  const result = await tx<{ id: string; blob: Blob } | undefined>(
    PHOTOS_STORE,
    'readonly',
    (store) => store.get(id),
  )
  return result?.blob ?? null
}

export async function deleteLogPhoto(id: string): Promise<void> {
  await tx(PHOTOS_STORE, 'readwrite', (store) => store.delete(id))
}

export async function saveLogEntry(entry: FestivalLogEntry): Promise<void> {
  await tx(ENTRIES_STORE, 'readwrite', (store) => store.put(entry))
}

export async function getAllLogEntries(): Promise<FestivalLogEntry[]> {
  return tx<FestivalLogEntry[]>(ENTRIES_STORE, 'readonly', (store) => store.getAll())
}

export async function deleteLogEntry(id: string): Promise<void> {
  const entries = await getAllLogEntries()
  const entry = entries.find((e) => e.id === id)
  if (entry) await deleteLogPhoto(entry.photoId)
  await tx(ENTRIES_STORE, 'readwrite', (store) => store.delete(id))
}

export async function deleteLogEntries(ids: string[]): Promise<void> {
  if (ids.length === 0) return

  const idSet = new Set(ids)
  const entries = await getAllLogEntries()
  const toDelete = entries.filter((entry) => idSet.has(entry.id))

  await Promise.all(toDelete.map((entry) => deleteLogPhoto(entry.photoId)))

  const db = await openDb()
  await new Promise<void>((resolve, reject) => {
    const transaction = db.transaction(ENTRIES_STORE, 'readwrite')
    const store = transaction.objectStore(ENTRIES_STORE)
    for (const id of ids) {
      store.delete(id)
    }
    transaction.oncomplete = () => resolve()
    transaction.onerror = () => reject(transaction.error)
  })
}

export async function clearAllLogEntries(): Promise<void> {
  const db = await openDb()
  await Promise.all([
    new Promise<void>((resolve, reject) => {
      const tx = db.transaction(PHOTOS_STORE, 'readwrite')
      tx.objectStore(PHOTOS_STORE).clear()
      tx.oncomplete = () => resolve()
      tx.onerror = () => reject(tx.error)
    }),
    new Promise<void>((resolve, reject) => {
      const tx = db.transaction(ENTRIES_STORE, 'readwrite')
      tx.objectStore(ENTRIES_STORE).clear()
      tx.oncomplete = () => resolve()
      tx.onerror = () => reject(tx.error)
    }),
  ])
}
