import { Analytics } from '@vercel/analytics/next';

export const metadata = {
  title: 'Stellar AI',
  description: 'AI-powered chat interface',
};

export default function RootLayout({ children }) {
  return (
    <html lang="en">
      <body>
        {children}
        <Analytics />
      </body>
    </html>
  );
}
