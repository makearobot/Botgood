local function isBotAllowed (userId, chatId)
  local hash = 'anti-bot:allowed:'..chatId..':'..userId
  local banned = redis:get(hash)
  return banned
end

local function allowBot (userId, chatId)
  local hash = 'anti-bot:allowed:'..chatId..':'..userId
  redis:set(hash, true)
end

local function disallowBot (userId, chatId)
  local hash = 'anti-bot:allowed:'..chatId..':'..userId
  redis:del(hash)
end

-- Is anti-bot enabled on chat
local function isAntiBotEnabled (chatId)
  local hash = 'anti-bot:enabled:'..chatId
  local enabled = redis:get(hash)
  return enabled
end

local function enableAntiBot (chatId)
  local hash = 'anti-bot:enabled:'..chatId
  redis:set(hash, true)
end

local function disableAntiBot (chatId)
  local hash = 'anti-bot:enabled:'..chatId
  redis:del(hash)
end

local function isABot (user)
  -- Flag its a bot 0001000000000000
  local binFlagIsBot = 4096
  local result = bit32.band(user.flags, binFlagIsBot)
  return result == binFlagIsBot
end

local function kickUser(userId, chatId)
  local chat = 'chat#id'..chatId
  local user = 'user#id'..userId
  chat_del_user(chat, user, function (data, success, result)
    if success ~= 1 then
      print('I can\'t kick '..data.user..' but should be kicked')
    end
  end, {chat=chat, user=user})
end

local function run (msg, matches)
  -- We wont return text if is a service msg
  if matches[1] ~= 'chat_add_user' and matches[1] ~= 'chat_add_user_link' then
    if msg.to.type ~= 'chat' then
      return 'انتی فلود در چنل ها کارمیکند'
    end
  end

  local chatId = msg.to.id
  if matches[1] == '+' then
    enableAntiBot(chatId)
    return 'انتی بات فعال شد و ربات ها کیک میشوند'
  end
  if matches[1] == '-' then
    disableAntiBot(chatId)
    return 'انتی بات غیرفعال شد و ربات ها کیک نمیشوند'
  end
  if matches[1] == '+' then
    local userId = matches[2]
    allowBot(userId, chatId)
    return 'Bot '..userId..' allowed'
  end
  if matches[1] == '-' then
    local userId = matches[2]
    disallowBot(userId, chatId)
    return 'Bot '..userId..' disallowed'
  end
  if matches[1] == 'chat_add_user' or matches[1] == 'chat_add_user_link' then
    local user = msg.action.user or msg.from
    if isABot(user) then
      print('It\'s a bot!')
      if isAntiBotEnabled(chatId) then
        print('ضد ربات فعال شد')
        local userId = user.id
        if not isBotAllowed(userId, chatId) then
          kickUser(userId, chatId)
        else
          print('این بات وجود دارد')
          local data = load_data(_config.moderation.data)
   		--[[if data[tostring(chat_id)] then
   			if data[tostring(chat_id)]['moderators'][tostring(v.id)] then
   				return nil
   			end
   		end]]
   		if data['admins'] then
   			if data['admins'][tostring(v.id)] then
   				return nil
   			end
   		end
        end
      end
    end
  end
end

  patterns = {
    '^[!/]bot (+) (%d+)$',
    '^[!/]bot (+) (%d+)$',
    '^[!/]bot (+)$',
    '^[!/]bot (-)$',
    '^!!tgservice (chat_add_user)$',
    '^!!tgservice (chat_add_user_link)$'
  },
  run = run
     Moderated = true }
