using System;
using System.Security.Cryptography;
using System.Text;

namespace PoliceBackgroundCheckSystem.Helpers
{
    public static class SecurityHelper
    {
        private const int Pbkdf2Iterations = 210000;
        private const int SaltSize = 16;
        private const int HashSize = 32;
        private const string HashPrefix = "PBKDF2-SHA256";

        public static string HashPassword(string password)
        {
            if (string.IsNullOrEmpty(password))
                throw new ArgumentException("Password cannot be empty.", "password");

            byte[] salt = new byte[SaltSize];
            using (RandomNumberGenerator random = RandomNumberGenerator.Create())
            {
                random.GetBytes(salt);
            }

            byte[] hash = DerivePasswordHash(password, salt, Pbkdf2Iterations);

            return HashPrefix + "$" +
                Pbkdf2Iterations.ToString(System.Globalization.CultureInfo.InvariantCulture) + "$" +
                Convert.ToBase64String(salt) + "$" +
                Convert.ToBase64String(hash);
        }

        public static bool VerifyPassword(string password, string storedHash)
        {
            if (string.IsNullOrEmpty(password) || string.IsNullOrEmpty(storedHash))
                return false;

            if (storedHash.StartsWith(HashPrefix + "$", StringComparison.Ordinal))
            {
                string[] parts = storedHash.Split('$');
                int iterations;
                byte[] salt;
                byte[] expected;

                if (parts.Length != 4 ||
                    !int.TryParse(
                        parts[1],
                        System.Globalization.NumberStyles.None,
                        System.Globalization.CultureInfo.InvariantCulture,
                        out iterations) ||
                    iterations < 10000 ||
                    iterations > 1000000)
                {
                    return false;
                }

                try
                {
                    salt = Convert.FromBase64String(parts[2]);
                    expected = Convert.FromBase64String(parts[3]);
                }
                catch (FormatException)
                {
                    return false;
                }

                if (salt.Length < 16 || expected.Length != HashSize)
                    return false;

                byte[] actual = DerivePasswordHash(password, salt, iterations);
                return FixedTimeEquals(actual, expected);
            }

            // Older accounts may contain the former unsalted SHA-256 format.
            if (IsHexSha256(storedHash))
            {
                using (SHA256 sha256 = SHA256.Create())
                {
                    byte[] actual = sha256.ComputeHash(Encoding.UTF8.GetBytes(password));
                    return FixedTimeEquals(actual, FromHex(storedHash));
                }
            }

            // Migrate existing plain-text passwords on the next successful sign-in.
            return FixedTimeEquals(
                Encoding.UTF8.GetBytes(password),
                Encoding.UTF8.GetBytes(storedHash));
        }

        public static bool NeedsRehash(string storedHash)
        {
            if (string.IsNullOrEmpty(storedHash) ||
                !storedHash.StartsWith(HashPrefix + "$", StringComparison.Ordinal))
                return true;

            string[] parts = storedHash.Split('$');
            int iterations;

            return parts.Length != 4 ||
                !int.TryParse(
                    parts[1],
                    System.Globalization.NumberStyles.None,
                    System.Globalization.CultureInfo.InvariantCulture,
                    out iterations) ||
                iterations < Pbkdf2Iterations;
        }

        public static string GenerateOtp()
        {
            const uint range = 900000;
            uint cutoff = UInt32.MaxValue - (UInt32.MaxValue % range);

            using (RandomNumberGenerator random = RandomNumberGenerator.Create())
            {
                byte[] bytes = new byte[4];
                uint sample;

                do
                {
                    random.GetBytes(bytes);
                    sample = BitConverter.ToUInt32(bytes, 0);
                }
                while (sample >= cutoff);

                return (100000 + (sample % range))
                    .ToString(System.Globalization.CultureInfo.InvariantCulture);
            }
        }

        public static string GenerateApplicationNumber()
        {
            return "GPS-" +
                   DateTime.Now.ToString("yyyy") +
                   "-" +
                   Guid.NewGuid()
                       .ToString("N")
                       .Substring(0, 8)
                       .ToUpper();
        }

        public static string GenerateTransactionId()
        {
            return "GOG-MM-" +
                   Guid.NewGuid()
                       .ToString("N")
                       .Substring(0, 8)
                       .ToUpper();
        }

        public static string GenerateCertificateNumber()
        {
            return "GPS-CERT-" +
                   DateTime.Now.ToString("yyyy") +
                   "-" +
                   Guid.NewGuid()
                       .ToString("N")
                       .Substring(0, 8)
                       .ToUpper();
        }

        private static byte[] DerivePasswordHash(
            string password,
            byte[] salt,
            int iterations)
        {
            using (Rfc2898DeriveBytes derive =
                new Rfc2898DeriveBytes(
                    password,
                    salt,
                    iterations,
                    HashAlgorithmName.SHA256))
            {
                return derive.GetBytes(HashSize);
            }
        }

        private static bool FixedTimeEquals(byte[] left, byte[] right)
        {
            if (left == null || right == null || left.Length != right.Length)
                return false;

            int difference = 0;
            for (int i = 0; i < left.Length; i++)
                difference |= left[i] ^ right[i];

            return difference == 0;
        }

        private static bool IsHexSha256(string value)
        {
            if (value.Length != 64)
                return false;

            for (int i = 0; i < value.Length; i++)
            {
                char c = value[i];
                if (!((c >= '0' && c <= '9') ||
                      (c >= 'a' && c <= 'f') ||
                      (c >= 'A' && c <= 'F')))
                    return false;
            }

            return true;
        }

        private static byte[] FromHex(string value)
        {
            byte[] bytes = new byte[value.Length / 2];
            for (int i = 0; i < bytes.Length; i++)
                bytes[i] = Convert.ToByte(value.Substring(i * 2, 2), 16);

            return bytes;
        }
    }
}