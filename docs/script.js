const revealItems = Array.from(document.querySelectorAll('[data-reveal]'));

if (revealItems.length) {
  const observer = new IntersectionObserver(
    (entries, obs) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('is-visible');
          obs.unobserve(entry.target);
        }
      });
    },
    { threshold: 0.2 }
  );

  revealItems.forEach((item, index) => {
    const delay = Math.min(index * 80, 320);
    item.style.setProperty('--reveal-delay', `${delay}ms`);
    observer.observe(item);
  });
}
