# cloudflare-ddns

Modifies a single Cloudflare **A** record if it doesn't match the current external IP. Requires a . Vars are for simplicity set in the script, so make sure access to the script is limited (e.g. **chmod 700 cloudflare-ddns.bash**.  All vars also have a prefix, should you want to use env vars instead.

### Reqs

- jq
- curl
- cloudflare API token

### Output/Logging

Output if successfull or failed. Optional output if the record is up to date.

### Cron example

```
* * * * * /path/to/cloudflare-ddns.bash >> /path/to/cloudflare-ddns.log
```
