# Secret management

Ez a dokumentum a Tipsterino secret-kezelési minimumot rögzíti dev/stage/prod környezetre.

## Alapelv
- Secret nem kerül commitba.
- A klienshez szükséges Supabase értékeket csak lokális, gitignore-olt fájlból vagy CI secretből adjuk át.
- Flutter parancsot mindig wrapperrel futtatunk (`./scripts/flutter.sh`, `./scripts/check.sh`, `./scripts/verify.sh`).

## Kötelezően gitignore-olt fájlok
- `app/.env`
- `.env.local`

## Engedélyezett kliens oldali runtime értékek
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`

Megjegyzés:
- Az `ANON_KEY` publikus szerephez tartozik, de a repo-ba ezt sem commitoljuk.
- A tényleges védelem alapja az RLS és a privilege contract.

## Tiltott értékek a repo-ban
- `SUPABASE_SERVICE_ROLE_KEY`
- bármilyen `service_role` token
- adatbázis jelszó / connection string
- JWT signing vagy encryption secret
- webhook vagy third-party master API key

## Dev workflow
1. Lokálisan töltsd ki az `app/.env` fájlt.
2. Használd a wrapper parancsokat:
   - `./scripts/flutter.sh run`
   - `./scripts/check.sh`
3. Codex task lezárás:
   - `./scripts/verify.sh --report codex/reports/<area>/<task_slug>.md`

## Stage/Prod workflow (CI)
- A szükséges értékeket CI secret store-ban tartsd (pl. GitHub Actions Secrets).
- Buildnél környezeti változóból add át a fordítási define-okat.
- Secret értéket ne logolj ki a pipeline outputban.

Példa CI lépés (szemléltető minta):
```bash
./scripts/flutter.sh build apk \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
```

## Incident handling
- Ha secret véletlenül repo-ba került, azonnal rotáld és vond vissza.
- A reportban csak az incidens tényét rögzítsd, az értéket soha.
