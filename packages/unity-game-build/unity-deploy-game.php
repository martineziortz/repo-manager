<?php
/**
 * Endpoint handler for GitHub unity game building and deployment process.
 *
 * When a game finishes building it will ping this script with the version information.
 * This will then execute the release-game command to deploy the new release.
 *
 * !! Important !!
 *
 * nginx (www-data group) must have read/write access to:
 *  The location of release archives (default: /var/www/<site>/games/archives)
 *  The location of extracted builds (default: /var/www/<site>/games/builds)
 *  The location of web accessible games (default: /var/www/<site>/web/games)
 *
 * These folders are based on what the release-game command needs, not this script.
 * It must also have execute access to the release-game command.
 */

// TRUE to always force a staging release (for testing).
define('FORCE_STAGING', true);

// data comes in as raw body text, so we need to set it up as JSON data.
$json = json_decode(file_get_contents('php://input') ?? '{}', true);

// repository will be in the pattern <org>/<project>
$repository = $json['repository'] ?? null;
// This will be the release tag. ex: 1.0.5, 2.1.5-alpha.5
$tag = $json['data']['release'] ?? null;
// Anything that isn't the main branch should be treated as a development release.
$environment = (FORCE_STAGING || ($json['ref_name'] ?? null) !== 'main') ? 'staging' : 'production';

list(,$project) = explode('/', $repository ?? '/', 2);
list(,$game) = explode('-', $project ?? '-', 2);

// This is necessary so nginx can auth using the gh cli.
$token = getenv('GITHUB_TOKEN');

if (empty($token) || empty($repository) || empty($tag) || empty($game)) {
  http_response_code(400);

  echo json_encode([
    'error' => true,
    'message' => 'Missing required information!',
    'data' => [
      'game' => $game ?? null,
      'repository' => $repository ?? null,
      'tag' => $tag ?? null,
      'project' => $project ?? null,
      'environment' => $environment ?? null,
      'token' => empty($token) ? 'missing' : 'found',
    ],
  ]);
  die;
}

// Command syntax: release-game mines 1.0.0-alpha.2 staging
// Must be executable by the nginx user or group (www-data).
// If it is not then the error code will be 126.
$cmd = implode(' ', [
  'release-game',
  escapeshellarg($game),
  escapeshellarg($tag),
  escapeshellarg($environment),
]);
// We can force gh to be authed by assigning an environment variable when we call it.
// We also need to redirect stderr so we can get the error messages when it fails.
$authed_cmd = sprintf('GITHUB_TOKEN=%s %s 2>&1', escapeshellarg($token), $cmd);

$output = null;
$exit_code = 0;
$result = exec($authed_cmd, $output, $exit_code);
$is_error = $exit_code > 0;

http_response_code($is_error ? 500 : 200);

echo json_encode([
  'error' => $is_error,
  'message' => $is_error ? 'Error' : 'OK',
  'code' => $exit_code,
  'data' => [
    'cmd' => $cmd,
    'result' => implode("\n", $output ?? []),
  ],
]);
