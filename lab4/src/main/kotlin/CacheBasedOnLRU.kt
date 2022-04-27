import com.googlecode.concurrentlinkedhashmap.ConcurrentLinkedHashMap

class CacheBasedOnLRU<K, V>(capacity: Long) :
    MutableMap<K, V> by ConcurrentLinkedHashMap.Builder<K, V>().maximumWeightedCapacity(capacity).build()
