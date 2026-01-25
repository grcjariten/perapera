const translations = {
  it: {
    "page-title": "PeraPera - Consolida la grammatica giapponese",
    "meta-description":
      "PeraPera \u00e8 una piccola app per esercitarti e consolidare la grammatica giapponese dopo lo studio. Sessioni rapide, pratica immediata.",
    "lang-aria": "Lingua",
    "nav-cta": "Apri su Google Play",
    "hero-pill": "Per chi ha gi\u00e0 studiato: qui consolidi.",
    "hero-title": "Consolida la grammatica giapponese, <span>3 minuti alla volta</span>.",
    "hero-lead": "Apri, scegli una regola, fai pratica subito.",
    "hero-action-primary": "Apri su Google Play",
    "hero-action-secondary": "Lascia feedback",
    "hero-note": "Solo Android per ora \u00b7 Non \u00e8 un corso completo",
    "hero-card-label": "Schermata reale",
    "hero-shot-alt": "Schermata PeraPera",
    "step-1": "<span>1</span> Scegli la regola",
    "step-2": "<span>2</span> Fai pratica",
    "step-3": "<span>3</span> Ripassa con flashcard",
    "showcase-title": "Dentro l'app",
    "showcase-note": "Schermate in inglese per ora.",
    "shot-1-alt": "Schermata: pratica rapida",
    "shot-1-caption": "Pratica rapida",
    "shot-2-alt": "Schermata: ripasso finale",
    "shot-2-caption": "Ripasso finale",
    "cta-title": "Apri e fai una sessione",
    "cta-text": "Tre minuti per capire se ti \u00e8 utile.",
    "cta-primary": "Apri su Google Play",
    "cta-secondary": "Lascia feedback",
    "feedback-title": "Feedback diretto",
    "feedback-text": "Due righe bastano.",
    "feedback-primary": "Apri il form",
    "feedback-secondary": "Scrivi una mail",
    footer: "\u00a9 2026 PeraPera - Una piccola app, migliorata ogni settimana.",
  },
  es: {
    "page-title": "PeraPera - Consolida la gram\u00e1tica japonesa",
    "meta-description":
      "PeraPera es una app peque\u00f1a para practicar y consolidar la gram\u00e1tica japonesa despu\u00e9s de estudiar. Sesiones r\u00e1pidas, pr\u00e1ctica inmediata.",
    "lang-aria": "Idioma",
    "nav-cta": "Abrir en Google Play",
    "hero-pill": "Para quien ya estudi\u00f3: aqu\u00ed consolidas.",
    "hero-title": "Consolida la gram\u00e1tica japonesa, <span>3 minutos cada vez</span>.",
    "hero-lead": "Abre, elige una regla y practica al instante.",
    "hero-action-primary": "Abrir en Google Play",
    "hero-action-secondary": "Deja feedback",
    "hero-note": "Solo Android por ahora \u00b7 No es un curso completo",
    "hero-card-label": "Pantalla real",
    "hero-shot-alt": "Pantalla PeraPera",
    "step-1": "<span>1</span> Elige la regla",
    "step-2": "<span>2</span> Practica",
    "step-3": "<span>3</span> Repasa con flashcards",
    "showcase-title": "Dentro de la app",
    "showcase-note": "Pantallas en ingl\u00e9s por ahora.",
    "shot-1-alt": "Pantalla: pr\u00e1ctica r\u00e1pida",
    "shot-1-caption": "Pr\u00e1ctica r\u00e1pida",
    "shot-2-alt": "Pantalla: repaso final",
    "shot-2-caption": "Repaso final",
    "cta-title": "Abre y haz una sesi\u00f3n",
    "cta-text": "Tres minutos para ver si te sirve.",
    "cta-primary": "Abrir en Google Play",
    "cta-secondary": "Deja feedback",
    "feedback-title": "Feedback directo",
    "feedback-text": "Bastan dos l\u00edneas.",
    "feedback-primary": "Abrir el formulario",
    "feedback-secondary": "Escribe un correo",
    footer: "\u00a9 2026 PeraPera - Una app peque\u00f1a, mejorada cada semana.",
  },
};

const defaultLang = "it";
const supportedLangs = Object.keys(translations);

const getInitialLang = () => {
  const params = new URLSearchParams(window.location.search);
  const urlLang = params.get("lang");
  if (urlLang && supportedLangs.includes(urlLang)) {
    return urlLang;
  }
  const storedLang = window.localStorage.getItem("perapera-lang");
  if (storedLang && supportedLangs.includes(storedLang)) {
    return storedLang;
  }
  return defaultLang;
};

const applyTranslations = (lang) => {
  const dictionary = translations[lang] || translations[defaultLang];

  document.documentElement.lang = lang;
  if (dictionary["page-title"]) {
    document.title = dictionary["page-title"];
  }
  const metaDescription = document.querySelector('meta[name="description"]');
  if (metaDescription && dictionary["meta-description"]) {
    metaDescription.setAttribute("content", dictionary["meta-description"]);
  }

  document.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.getAttribute("data-i18n");
    const value = dictionary[key];
    if (!value) {
      return;
    }
    const attr = el.getAttribute("data-i18n-attr");
    if (attr) {
      el.setAttribute(attr, value);
      return;
    }
    if (el.getAttribute("data-i18n-html") === "true") {
      el.innerHTML = value;
    } else {
      el.textContent = value;
    }
  });

  document.querySelectorAll(".lang-btn").forEach((button) => {
    button.classList.toggle("is-active", button.dataset.lang === lang);
  });

  window.localStorage.setItem("perapera-lang", lang);
};

const langButtons = Array.from(document.querySelectorAll(".lang-btn"));
if (langButtons.length) {
  langButtons.forEach((button) => {
    button.addEventListener("click", () => {
      const lang = button.dataset.lang;
      if (!lang || !supportedLangs.includes(lang)) {
        return;
      }
      applyTranslations(lang);
    });
  });
}

applyTranslations(getInitialLang());

const revealItems = Array.from(document.querySelectorAll("[data-reveal]"));

if (revealItems.length) {
  const observer = new IntersectionObserver(
    (entries, obs) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add("is-visible");
          obs.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );

  revealItems.forEach((item, index) => {
    const delay = Math.min(index * 80, 320);
    item.style.setProperty("--reveal-delay", `${delay}ms`);
    observer.observe(item);
  });
}
