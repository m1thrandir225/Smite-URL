import RediStack
import Vapor
import NIO

func expireRedisKey(_ key: RedisKey, redis: Vapor.Request.Redis) {
	let expireDuration = TimeAmount.hours(6)
	_ = redis.expire(key, after: expireDuration)
}