#!lua name=rate_limiters
local function sliding_window_counter(KEYS, ARGV)
    local current_time = redis.call('TIME')
    local key = KEYS[1]
    local max_requests = tonumber(ARGV[1])
    local window = tonumber(ARGV[2])
    local trim_time = tonumber(current_time[1]) - window
    redis.call('ZREMRANGEBYSCORE', key, 0, trim_time)
    local request_count = redis.call('ZCARD',key)

    if request_count < tonumber(max_requests) then
        redis.call('ZADD', key, current_time[1], current_time[1] .. current_time[2])
        redis.call('EXPIRE', key, window)
        return 0
    end
    return 1
end

redis.register_function('sliding_window_counter', sliding_window_counter)
