const revealItems = Array.from(document.querySelectorAll('[data-reveal]'));

revealItems.forEach((item, index) => {
  const delay = 120 * index;
  setTimeout(() => {
    item.classList.add('is-visible');
  }, delay);
});
