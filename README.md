# Sandbox for honeybot

Emulates code execution for bash and php

```
{
   "name": "honeybot",
   "storages": {
      "redis": [
         {
            "socket": "/var/run/redis/redis.sock",
            "connection_method": "unix",
            "name": "redis_local"
         }
      ]
   },
   "plugins": {
      "honeybot": [],
	  "sandbox":[{"server":"sandbox.appsec.online"}]
   },
   "actions": {}
}
```
