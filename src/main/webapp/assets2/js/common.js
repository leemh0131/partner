document.addEventListener('DOMContentLoaded', function () {
    const dropdowns = document.querySelectorAll('.dropdown');

    dropdowns.forEach(dropdown => {
        const toggle = dropdown.querySelector('.dropdown-toggle');
        const menu = dropdown.querySelector('.dropdown-menu');
        const links = menu.querySelectorAll('a');

        if (!toggle || !menu) return;

        toggle.addEventListener('click', function(e) {
            e.stopPropagation();
            dropdowns.forEach(d => d !== dropdown && d.classList.remove('active'));
            dropdown.classList.toggle('active');
        });

        links.forEach(link => {
            link.addEventListener('click', function(e) {
                e.preventDefault();
                links.forEach(l => l.classList.remove('on'));
                this.classList.add('on');

                dropdown.classList.remove('active');
                toggle.textContent = this.textContent;

                toggle.classList.add('selected'); 
            });
        });
    });

    document.addEventListener('click', function() {
        dropdowns.forEach(d => d.classList.remove('active'));
    });
});
$(document).ready(function(){
    $('.modal-open').on('click', modalOpen);
    $('.modal-close').on('click', modalClose);
    $('.modal-container').on('click', function(e){
        if (!$(e.target).closest('.modal-wrapper').length) {
            $('html').removeClass('modalOn');
            $(this).fadeOut(0);
            $(this).delay(50).fadeOut(0);
            $(this).removeClass('show');
            $('html').css('overflow-y','auto');
        }
    });
});
function modalOpen(modalID){
    $('html').css('overflow-y','hidden');
    $('.modal-container').fadeOut(0);
    $('.modal-container').removeClass('show');
    $(this).data('modal') ? modalID = $(this).data('modal') : '';
    $('.modal-container.show').length > 0 ? $('#' + modalID).css({
        'z-index': $('.modal-container.show').css('z-index') + 1,
        'background': 'transparent'
    }) : '';
    $('#' + modalID).css('display', 'flex').focus();
    $('#' + modalID + ' .modal-wrapper').delay(100).fadeIn(100).focus();
    $('#' + modalID).addClass('show').focus();

    return false;
}
function modalClose(){
    $('html').css('overflow-y','auto');
    $(this).closest('.modal-container').fadeOut(0);
    $(this).closest('.modal-container').removeClass('show');
}
