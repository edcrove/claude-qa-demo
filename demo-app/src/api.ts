export type Channel = {
  slug: string;
  name: string;
  genre: string;
};

const CHANNELS: Channel[] = [
  { slug: 'news', name: 'News Channel', genre: 'news' },
  { slug: 'movies', name: 'Movies Channel', genre: 'movies' },
  { slug: 'sports', name: 'Sports Channel', genre: 'sports' },
];

const SLUG_PATTERN = /^[a-z0-9-]+$/;

export function getChannelBySlug(slug: string): Channel | null {
  if (!SLUG_PATTERN.test(slug)) {
    throw new Error(`invalid slug: ${JSON.stringify(slug)}`);
  }
  return CHANNELS.find(c => c.slug === slug) ?? null;
}
