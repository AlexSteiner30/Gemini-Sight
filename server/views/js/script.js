const nav = document.getElementsByTagName('nav')[0];

window.addEventListener('scroll', () => {
    if (window.scrollY > 0) {
        nav.attr('class', 'scrolled');
    } else {
        nav.attr('class', '');
    }
});