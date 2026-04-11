<?php
// GET /api/auth/me.php
// Header: Authorization: Bearer <token>
// Returns: { user }
require_once __DIR__ . '/../config/helpers.php';
cors();

$user = requireAuth();
respond(['user' => sanitiseUser($user)]);
