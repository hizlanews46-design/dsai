import { z } from "zod";

const envSchema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(3001),
  HOST: z.string().default("0.0.0.0"),
  LOG_LEVEL: z.enum(["fatal", "error", "warn", "info", "debug", "trace"]).default("info"),

  DATABASE_URL: z.string().min(1),
  REDIS_URL: z.string().min(1),
  REDIS_OTP_PREFIX: z.string().default("otp:"),
  REDIS_OTP_TTL_SECONDS: z.coerce.number().int().positive().default(180),
  OTP_MAX_ATTEMPTS: z.coerce.number().int().positive().default(3),
  OTP_WINDOW_SECONDS: z.coerce.number().int().positive().default(900),
  OTP_LENGTH: z.coerce.number().int().min(4).max(8).default(6),
  OTP_DEV_ECHO: z
    .string()
    .optional()
    .transform((v) => v === "true"),

  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_REFRESH_SECRET: z.string().min(32),
  JWT_ACCESS_EXPIRES_IN: z.string().default("15m"),
  JWT_REFRESH_EXPIRES_IN: z.string().default("30d"),
  JWT_ISSUER: z.string().default("nexus-comm"),
  JWT_AUDIENCE: z.string().default("nexus-mobile"),

  COOKIE_DOMAIN: z.string().optional().default(""),
  COOKIE_SECURE: z
    .string()
    .optional()
    .transform((v) => v === "true"),
  COOKIE_SAMESITE: z.enum(["strict", "lax", "none"]).default("strict"),
  REFRESH_COOKIE_NAME: z.string().default("nexus_rt"),

  CORS_ORIGINS: z
    .string()
    .default("http://localhost:5173")
    .transform((v) => v.split(",").map((s) => s.trim()).filter(Boolean)),

  TWILIO_ACCOUNT_SID: z.string().optional().default(""),
  TWILIO_AUTH_TOKEN: z.string().optional().default(""),
  TWILIO_FROM_NUMBER: z.string().optional().default(""),

  SMS_API_URL: z.string().optional().default(""),
  SMS_API_KEY: z.string().optional().default(""),
  SMS_API_FROM: z.string().optional().default(""),

  FCM_PROJECT_ID: z.string().optional().default(""),
  FCM_CLIENT_EMAIL: z.string().optional().default(""),
  FCM_PRIVATE_KEY: z.string().optional().default(""),
  GOOGLE_APPLICATION_CREDENTIALS: z.string().optional().default(""),

  BACKUP_KEY_PEPPER: z.string().min(16),
  BACKUP_CHALLENGE_TTL_SECONDS: z.coerce.number().int().positive().default(120),

  SIGNALING_PING_INTERVAL_MS: z.coerce.number().int().positive().default(25000),
  SIGNALING_MAX_BUFFER_SIZE: z.coerce.number().int().positive().default(1_048_576),

  DSAIALAP_B2B_KEYS: z.string().optional().default(""),
  DSAIALAP_PUBLIC_HOST: z.string().optional().default("dsaialap.banglarvoice24news.com"),
  MASKED_ORIGINS: z
    .string()
    .optional()
    .default("")
    .transform((v) => v.split(",").map((s) => s.trim()).filter(Boolean)),
});

export type Env = z.infer<typeof envSchema>;

export function loadEnv(raw: NodeJS.ProcessEnv = process.env): Env {
  const parsed = envSchema.safeParse(raw);
  if (!parsed.success) {
    const issues = parsed.error.issues
      .map((i) => `${i.path.join(".")}: ${i.message}`)
      .join("; ");
    throw new Error(`Invalid environment: ${issues}`);
  }
  return parsed.data;
}

export const env = loadEnv();
