<?php
class JWT {
    private static $secret = 'your-secret-key-here'; // In production, use environment variable

    public static function encode($payload) {
        $header = json_encode(['typ' => 'JWT', 'alg' => 'HS256']);

        $payload['iat'] = time();
        $payload['exp'] = time() + (24 * 60 * 60); // 24 hours
        $payloadEncoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode(json_encode($payload)));

        $headerEncoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));

        $signature = hash_hmac('sha256', $headerEncoded . "." . $payloadEncoded, self::$secret, true);
        $signatureEncoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));

        return $headerEncoded . "." . $payloadEncoded . "." . $signatureEncoded;
    }

    public static function decode($token) {
        $parts = explode('.', $token);

        if (count($parts) !== 3) {
            throw new Exception('Invalid token format');
        }

        $header = base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[0]));
        $payload = base64_decode(str_replace(['-', '_'], ['+', '/'], $parts[1]));
        $signature = $parts[2];

        $expectedSignature = hash_hmac('sha256', $parts[0] . "." . $parts[1], self::$secret, true);
        $expectedSignatureEncoded = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($expectedSignature));

        if (!hash_equals($signature, $expectedSignatureEncoded)) {
            throw new Exception('Invalid token signature');
        }

        $payloadData = json_decode($payload, true);

        if ($payloadData['exp'] < time()) {
            throw new Exception('Token has expired');
        }

        return $payloadData;
    }

    public static function getUserFromToken() {
        $headers = getallheaders();

        if (!isset($headers['Authorization'])) {
            return null;
        }

        $authHeader = $headers['Authorization'];
        $token = str_replace('Bearer ', '', $authHeader);

        try {
            return self::decode($token);
        } catch (Exception $e) {
            return null;
        }
    }
}
?>