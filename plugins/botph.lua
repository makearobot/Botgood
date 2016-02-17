do

function run(msg, matches)
send_contact(get_receiver(msg), "+639080257615", "Monster", "Bot", ok_cb, false)
end

return {
patterns = {
"^!botph$"

},
run = run
}

end
