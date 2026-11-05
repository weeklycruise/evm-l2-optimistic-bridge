interface CacheEntry<V> {
  value: V;
  expiresAt: number;
}

export class TtlLruCache<K, V> {
  private map = new Map<K, CacheEntry<V>>();

  constructor(private capacity: number = 200, private defaultTtlMs: number = 60000) {}

  public get(key: K): V | undefined {
    const entry = this.map.get(key);
    if (!entry) return undefined;
    if (Date.now() > entry.expiresAt) {
      this.map.delete(key);
      return undefined;
    }
    // Refresh position for LRU
    this.map.delete(key);
    this.map.set(key, entry);
    return entry.value;
  }

  public set(key: K, value: V, ttlMs: number = this.defaultTtlMs): void {
    if (this.map.size >= this.capacity) {
      const oldestKey = this.map.keys().next().value;
      if (oldestKey !== undefined) this.map.delete(oldestKey);
    }
    this.map.set(key, { value, expiresAt: Date.now() + ttlMs });
  }
}
