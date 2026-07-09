import { useCallback, useEffect, useState } from 'react'

const NOTIF_KEY = 'notificationsEnabled'
const REMINDER_KEY = 'reminderTime'

export function useSettings() {
  const [notificationsEnabled, setNotificationsEnabled] = useState(() => {
    return localStorage.getItem(NOTIF_KEY) === 'true'
  })

  const [reminderTime, setReminderTime] = useState(() => {
    const saved = localStorage.getItem(REMINDER_KEY)
    return saved ? parseInt(saved, 10) : 30
  })

  useEffect(() => {
    localStorage.setItem(NOTIF_KEY, String(notificationsEnabled))
  }, [notificationsEnabled])

  useEffect(() => {
    localStorage.setItem(REMINDER_KEY, String(reminderTime))
  }, [reminderTime])

  const requestNotificationPermission = useCallback(async () => {
    if (!('Notification' in window)) return false
    const permission = await Notification.requestPermission()
    return permission === 'granted'
  }, [])

  const enableNotifications = useCallback(async () => {
    const granted = await requestNotificationPermission()
    if (granted) {
      setNotificationsEnabled(true)
    }
    return granted
  }, [requestNotificationPermission])

  const disableNotifications = useCallback(() => {
    setNotificationsEnabled(false)
  }, [])

  return {
    notificationsEnabled,
    reminderTime,
    setReminderTime,
    enableNotifications,
    disableNotifications,
    requestNotificationPermission,
  }
}
