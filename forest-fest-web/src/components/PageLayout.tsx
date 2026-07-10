import { Link } from 'react-router-dom'
import './PageLayout.css'

interface PageLayoutProps {
  title: string
  children: React.ReactNode
  backTo?: string
  rightAction?: React.ReactNode
}

export function PageLayout({ title, children, backTo = '/', rightAction }: PageLayoutProps) {
  return (
    <div className="page-layout">
      <header className="page-header">
        <Link to={backTo} className="page-header-btn" aria-label="Go back">
          ←
        </Link>
        <h1 className="page-header-title">{title}</h1>
        <div className="page-header-action">{rightAction ?? <span className="page-header-spacer" />}</div>
      </header>
      <main className="page-content">{children}</main>
    </div>
  )
}
