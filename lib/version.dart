/// Single source of truth for the app's identity and update endpoint.
///
/// [kAppVersion] is baked into the binary and shown on the About screen. The
/// release tooling (`deploy/release.sh`) reads this same value to tag the
/// GitHub release and to stamp the bundle's `VERSION` file, so the number the
/// app displays always matches what the updater compares against.
library;

const String kAppName = 'Dyscover ABC';
const String kAppTagline = 'A touch-first ABC kiosk for young learners';
const String kAppVersion = '1.0.1';

/// GitHub repo the over-the-air updater pulls releases from.
const String kGithubRepo = 'sunbiz/dyscover';
const String kGithubUrl = 'https://github.com/$kGithubRepo';

const String kLabName = 'Purkayastha Lab for Health Innovation';
const String kLabUrl = 'https://plhi.lab.indianapolis.iu.edu';
const String kLabAffiliation =
    'Luddy School of Informatics, Computing & Engineering, IU Indianapolis';
