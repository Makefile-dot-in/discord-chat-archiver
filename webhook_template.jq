def get_full_name($name): $name | [.username, .discriminator] | join("#");
def link_ref_message: "https://discord.com/channels/" + ([$guild, $channel, $ref_msg] | join("/"));
def embed_map:
  {
    "1": [{title: "User Added", description: ("Added "+get_full_name(.mentions[]))}],
    "2": [{title: "User Removed", description: ("Removed "+get_full_name(.mentions[]))}],
    "3": [{title: "User Called", description: "Started a call."}],
    "4": [{title: "User Changed Channel Name", description: "The channel name was changed to above."}],
    "5": [{title: "User Changed Channel Icon", description: "changed channel icon."}],
    "6": [{title: "User Pinned Message", description: ("Pinned [message]("+link_ref_message+").")}],
    "19":[{title: "Reply", description: ("Replied to [this message]("+link_ref_message+").")}]
};
def gen_embeds: 
  embed_map[(.type | tostring)] as $embed_func |
  if $embed_func
  then $embed_func
  else [] end;
def str_emoji($e):
  $e | if .id then "<:"+.name+":"+.id+">"
  else .name end;
def reacts:
  if .reactions then
    ["\nReactions: " + (.reactions[] | str_emoji(.emoji) + ": " + (.count | tostring))] | join("\n")
  else "" end;

{
	content: (.content+reacts),
	username: .author.username,
	avatar_url: ("https://cdn.discordapp.com/avatars/" + .author.id + "/" + .author.avatar + ".png"),
	embeds: (gen_embeds + .embeds),
	allowed_mentions: {parse:[]}
}
