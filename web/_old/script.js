// Replaces all glossary links with tooltips that contain the description of the glossary
var createTooltips = function() {
	var glossary_items = $("a[href^='#glo:']");
		
		$.each(glossary_items, function(index, glossary_entry) {
			// fetch glossary item description by id
			var id = $(glossary_entry).attr("href").split(":")[1];
			var word = $(glossary_entry).text();
			var description = $("a[id^='glo:" + id + "']").parent().next().text();
			
			// create tooltip and insert after initial glossary item
			var tooltip = $("<div></div>");
			var tooltiptext = $("<span></span>");
			
			tooltiptext
				.text(description)
				.addClass("tooltiptext");	
			tooltip
				.text(word)
				.addClass("tooltip")
				.append(tooltiptext)
				.insertAfter($(glossary_entry));
			
			// remove initial glossary item
			$(glossary_entry).remove();
		});
};

	
// Hide the glossary header and all glossary items
var hideGlossary = function() {
	var glossary_title = $("h3:contains('Glossar')");
	var glossary_items = glossary_title.nextAll();
	glossary_title.remove();
	glossary_items.remove();
};

$(document).ready(createTooltips);
$(document).ready(hideGlossary);
