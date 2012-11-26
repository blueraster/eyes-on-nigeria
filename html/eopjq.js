/* JQuery functions; require jquery-1.4.1.min.js or later in order to work */ 
$(document).ready(function() {

	/* ---------- BEGIN: Resize images ------------ */
	
	$('a.resizable').live('click', function(e) {
		e.preventDefault();
		var myHref = $(this).attr('href');
		var imgHref = $('> span > img[class!=closeButton]', this).attr('src');
		$('> span > img[class!=closeButton]', this).attr('src',myHref);
		$(this).attr('href',imgHref);	
		
		/* If close button does not exist, we are replacing Thumbnail with Big image: */
		
		if ($(this).find('img:first').attr('class')!='closeButton') {
			$(this).css('float','none');
			$(this).find('img:first').before('<img src="images/bttn_close.gif" class="closeButton" /><br class="brclose" />');
			$(this).after('<br class="brclose" />');
			$(this).find('> span > span.imgCaption').hide();
			/* NB .show() doesn't work in WebKit browsers (Safari & Chrome) too well, so use manual css instead: */
			$(this).find('> span > span.photoCredit').css('display','block');
		}
		
		/* Else, we are replacing Big image with Thumbnail: */
		
		else {
			$(this).css('float','left');
			$(this).find('img[class=closeButton]:first').remove();
			$(this).parent().find('br[class=brclose]').remove();
			/* NB .show() doesn't work in WebKit browsers (Safari & Chrome) too well, so use manual css instead: */
			$(this).find('> span > span.photoCredit').css('display','block');
			$(this).find('> span > span.photoCredit').hide();
		}
	});
	/* ---------- END: Resize images ------------ */


	/* ---------- BEGIN: Replace screencap with video ------------ */
	
	$('a#resizableVideo01').live('click', function(e) {
		e.preventDefault();
		
		/* If close button does not exist, we are replacing still with video: */
		
		if ($(this).find('img:first').attr('class')!='closeButton') {
			var myNewContent = $('#video01').html();
			$(this).find('img:first').before('<img src="images/bttn_close.gif" id="cb" class="closeButton" /><br class="brclose" />');
			$(this).after('<br class="brclose" />');
			$('span.imgCaption').hide();
			$('> span > img[class!=closeButton]', this).replaceWith(myNewContent);
		} 
		
		/* Else, we are replacing video with still: */
		
		else {
			var myNewContent = $('#video01_still').html();
			$(this).find('img[class=closeButton]:first').remove();
			$(this).parent().find('br[class=brclose]').remove();
			$(this).html(myNewContent);
			$('span.imgCaption').show();
		}
	});
	/* ---------- END: Replace screencap with video ------------ */
	
	
	/* ---------- BEGIN: Amnesty Logo Hover ------------ */
	
	$('a#aiusaLogo').hover(function() {
		$('> img', this).attr('src','images/AIUSA_Logo50_over.jpg');
	}, function() {
		$('> img', this).attr('src','images/AIUSA_Logo50.jpg');
	});
	/* ---------- END: Amnesty Logo Hover ------------ */

	/* ---------- BEGIN: AAAS Logo Hover ------------ */
	
	$('a#aaasLogo').hover(function() {
		$('> img', this).attr('src','images/aaasON.gif');
	}, function() {
		$('> img', this).attr('src','images/aaas.gif');
	});
	/* ---------- END: AAAS Logo Hover ------------ */

});
