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

export function getChannelBySlug(slug: string): Channel | null {
  return CHANNELS.find(c => c.slug === slug) ?? null;
}
