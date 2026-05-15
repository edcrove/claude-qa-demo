import { describe, it, expect } from 'vitest';
import { getChannelBySlug } from '../src/api.js';

describe('GET /api/v1/channels/:slug', () => {
  it('returns the channel for a known slug', () => {
    const result = getChannelBySlug('news');
    expect(result).toEqual({ slug: 'news', name: 'News Channel', genre: 'news' });
  });

  it('returns null for an unknown slug', () => {
    expect(getChannelBySlug('does-not-exist')).toBeNull();
  });
});
