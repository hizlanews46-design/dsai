import { logger } from "../../lib/logger.js";
import type { B2bTenant } from "./b2b-key.service.js";

export interface B2bWebhookEvent {
  type: string;
  occurredAt: string;
  tenantId: string;
  payload: Record<string, unknown>;
}

export class WebhookDispatcher {
  async dispatch(tenant: B2bTenant, event: Omit<B2bWebhookEvent, "tenantId" | "occurredAt">): Promise<boolean> {
    if (!tenant.webhookUrl) return false;
    const body: B2bWebhookEvent = {
      type: event.type,
      payload: event.payload,
      tenantId: tenant.id,
      occurredAt: new Date().toISOString(),
    };
    try {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), 2500);
      const res = await fetch(tenant.webhookUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-Dsaialap-Event": event.type,
          "X-Dsaialap-Tenant": tenant.id,
        },
        body: JSON.stringify(body),
        signal: controller.signal,
      });
      clearTimeout(timer);
      if (!res.ok) {
        logger.warn({ status: res.status, tenant: tenant.id }, "b2b webhook non-2xx");
        return false;
      }
      return true;
    } catch (err) {
      logger.warn({ err, tenant: tenant.id }, "b2b webhook dispatch failed");
      return false;
    }
  }
}

export const webhookDispatcher = new WebhookDispatcher();
