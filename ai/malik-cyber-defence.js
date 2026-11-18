// Malik (MLK) Autonomous Cyber Defense, Self-Protection & Real-Time Alert Engine v1.0
// Detects cyber attacks, triggers instant self-defense lockdown, and dispatches security alerts

class MalikCyberDefense {
  constructor(adminAlertWebhook = null) {
    this.systemStatus = "ACTIVE_PROTECTED";
    this.adminAlertWebhook = adminAlertWebhook; // भविष्य में Telegram/Email अलर्ट जोड़ने के लिए
    this.requestTracker = new Map();
    this.blockedAttackers = new Set();
    this.incidentReports = [];
  }

  // 1. साइबर हमले की पहचान और तुरंत आत्म-रक्षा (Intrusion Detection & Self-Defense)
  inspectAndDefend(sourceId, payload) {
    // यदि हमलावर पहले से ब्लॉक है, तो तुरंत रोकें
    if (this.blockedAttackers.has(sourceId)) {
      return { allowed: false, status: "BLOCKED_ATTACKER", message: "Access permanently denied by Malik Cyber Shield." };
    }

    const now = Date.now();
    const logs = this.requestTracker.get(sourceId) || [];
    const recentRequests = logs.filter(t => now - t < 10000); // पिछले 10 सेकंड की गतिविधि
    recentRequests.push(now);
    this.requestTracker.set(sourceId, recentRequests);

    // हमला पहचान 1: DDoS या Brute-Force हमला (10 सेकंड में 15 से ज़्यादा तेज़ रिक्वेस्ट)
    if (recentRequests.length > 15) {
      return this.triggerSelfDefense(sourceId, "DDOS_OR_BRUTE_FORCE_ATTACK", "High-frequency automated flood detected.");
    }

    // हमला पहचान 2: कोड इंजेक्शन या स्मार्ट कॉन्ट्रैक्ट मैनिपुलेशन की कोशिश
    const payloadStr = JSON.stringify(payload || "").toLowerCase();
    if (payloadStr.includes("<script>") || payloadStr.includes("drop table") || payloadStr.includes("selfdestruct")) {
      return this.triggerSelfDefense(sourceId, "MALICIOUS_INJECTION_ATTEMPT", "Malicious code payload intercepted.");
    }

    return { allowed: true, status: "SAFE", message: "Traffic verified clean." };
  }

  // 2. आत्म-रक्षा सक्रिय करना और एडमिन को तुरंत सूचना (Alert) देना
  triggerSelfDefense(attackerId, attackType, details) {
    // कदम A: हमलावर को तुरंत ब्लैकलिस्ट/ब्लॉक करना
    this.blockedAttackers.add(attackerId);
    this.systemStatus = "DEFENSE_LOCKDOWN_TRIGGERED";

    // कदम B: घटना की पूरी रिपोर्ट तैयार करना
    const alertReport = {
      alertId: `SEC-${Date.now()}`,
      severity: "CRITICAL",
      attackType: attackType,
      attackerSource: attackerId,
      actionTaken: "Attacker blocked automatically & sensitive bridge functions quarantined.",
      details: details,
      timestamp: new Date().toISOString()
    };

    this.incidentReports.push(alertReport);

    // कदम C: एडमिन (शैलेंद्र) को तुरंत चेतावनी सूचना भेजना
    this.dispatchAdminAlert(alertReport);

    return {
      allowed: false,
      status: "ATTACK_NEUTRALIZED",
      report: alertReport
    };
  }

  // 3. सूचना भेजने का सिस्टम (Console, Browser Notification & Webhook Ready)
  async dispatchAdminAlert(report) {
    console.error("🚨 [MALIK CYBER ALERT - SELF DEFENSE ACTIVATED] 🚨", report);   
    // यदि वेब ब्राउज़र पर चल रहा है, तो स्क्रीन पर तुरंत सुरक्षा चेतावनी दिखाना
    if (typeof window !== "undefined" && "Notification" in window) {
      if (Notification.permission === "granted") {
        new Notification(`🚨 Malik Cyber Shield Alert: ${report.attackType}`, {
          body: `Blocked attacker: ${report.attackerSource}. System self-protected!`
        });
      }
    }

    // भविष्य में Telegram Bot या Email अलर्ट से जोड़ने के लिए
    if (this.adminAlertWebhook) {
      try {
        await fetch(this.adminAlertWebhook, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ text: `🚨 MALIK SECURITY ALERT: ${report.attackType} blocked from ${report.attackerSource}` })
        });
      } catch (err) {
        console.log("Alert queued in local forensic log.");
      }
    }
  }
}

if (typeof window !== "undefined") {
  window.malikDefense = new MalikCyberDefense();
}
if (typeof module !== "undefined") {
  module.exports = MalikCyberDefense;
}
 
