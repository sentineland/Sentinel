import { kv } from '@vercel/kv';

function format_date() {
  const d = new Date();
  const dd = String(d.getDate()).padStart(2, '0');
  const mm = String(d.getMonth() + 1).padStart(2, '0');
  const yyyy = d.getFullYear();
  return `${dd}/${mm}/${yyyy}`;
}

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'method_not_allowed' });

  const { discord_id, discord_username } = req.body;
  if (!discord_id || !discord_username) return res.status(400).json({ error: 'missing_fields' });

  // Get existing UID table
  const uid_table = (await kv.get('uid_table')) || {};
  const time = format_date();

  // Check if discord_id exists
  for (let uid in uid_table) {
    if (uid_table[uid].discord_id === discord_id) {
      if (!uid_table[uid].first_execution) uid_table[uid].first_execution = time;
      uid_table[uid].last_execution = time;
      await kv.set('uid_table', uid_table);
      return res.json({
        uid,
        discord_username: uid_table[uid].discord_username,
        first_execution: uid_table[uid].first_execution,
        last_execution: uid_table[uid].last_execution
      });
    }
  }

  // Create new UID
  const new_uid = Object.keys(uid_table).length + 1;
  uid_table[new_uid] = { discord_username, discord_id, first_execution: time, last_execution: time };
  await kv.set('uid_table', uid_table);

  res.json({
    uid: new_uid,
    discord_username,
    first_execution: time,
    last_execution: time
  });
}
