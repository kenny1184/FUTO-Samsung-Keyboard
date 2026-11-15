# S25 Keyboard

Een aangepaste FUTO Keyboard-build voor persoonlijk gebruik, gebaseerd op de Samsung Galaxy S25 Ultra. Nederlands en Engels krijgen het S25-profiel met vaste cijferrij, long-press-symbolen en twee symboolpagina’s. Veeg horizontaal over de spatiebalk om van taal te wisselen. Houd de spatiebalk ingedrukt om de cursor te verplaatsen.

Versie 0.2.0 gebruikt compactere rijen in portretmodus en afgeronde toetsvlakken. Het thema **Samsung S25 Ultra** geeft gewone toetsen, functietoetsen, de spatiebalk en Enter afzonderlijke tinten. De werkbalk gebruikt standaard één rij. Bij een actieve taalveeginstelling geven de pijlen op de spatiebalk aan dat je kunt wisselen tussen de ingeschakelde talen.

De APK heeft pakket-ID `org.futo.inputmethod.latin.s25` en is afzonderlijk te installeren. Schakel na installatie **S25 Keyboard (modified FUTO)** in bij de Android-toetsenborden en selecteer het als invoermethode.

FUTO verzorgt lokaal swipe-typen, dicteren en woordsuggesties. Gepersonaliseerde woordenboeken, contactnamen, metrieken en klembordgeschiedenis staan standaard uit. De APK heeft geen internetmachtiging en Android-back-up staat uit.

## Build

De workflow op `dev/samsung-s25-ultra` gebruikt Java 21 en bouwt `assembleUnstableDebug` op de FUTO-revisie die de basisbuild heeft gebruikt. De ondertekende test-APK staat als **S25-Keyboard-APK** bij de Actions-run.

Voor een lokale build met Android SDK 35, Java 21 en Git LFS:

```bash
git clone https://github.com/futo-org/android-keyboard.git futo
git -C futo checkout 7d61ab4132cfcbb7aa713190d934f0125dc38b03
git -C futo submodule update --init --recursive --depth 1
git -C futo/java/assets/futo-swipe lfs install --local --skip-repo
git -C futo/java/assets/futo-swipe lfs pull
bash scripts/apply-layout.sh futo
(cd futo && VERSION_CODE=1 VERSION_NAME=0.2.0 ./gradlew assembleUnstableDebug)
bash scripts/verify-apk.sh futo/build/outputs/apk/unstable/debug/*.apk
```

De FUTO Source First-licentie staat in [LICENSE.md](LICENSE.md). De oorspronkelijke licenties, kennisgevingen en betaalopties zijn onderdeel van de build.
