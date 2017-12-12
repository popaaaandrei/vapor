Title: Caching
Audience Level: Intermediate
Style: Core
Prerequisites: Codable, Routing, Services
Most important concepts: Cache API
Sample app name: Pokedex
Sample app description: Record which Pokemon you have caught.

Outline (please annotate each section Theory/Instruction/Reference):

  * Introduction [Theory]: 
  	* Theory: Using memory to make slow processes faster.
  	* Key-value: Explain the concept of key-value caches and expiration dates.
  	* Services: Mention popular caching services such as Redis, memcached, memory.
  * Getting Started [Instruction]
    * Configure application to use in-memory (test) cache.
    * The Pokedex is suffering from slow API fetches, learn how to cache the result.
    * Look at additional methods on the cache API.
    * Explain the limitations of in memory cache and discuss cache services.
  * Redis [Instruction]
    * Configure previous example to use redis.
  * Fluent [Instruction]
  	* Configure previous example to use Fluent cache.
  * Where To Go From Here?