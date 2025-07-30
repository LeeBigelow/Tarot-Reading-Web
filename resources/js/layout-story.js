story_title = 'Tarot Reading Web - Story - 5';

story_html = `
	<h1>Story</h1>
	<div id="layout-container">
		<div class="card card-deck">
			<img id="deck-image"/>
			<div id="deck-title"></div>
		</div>
		<div id="card-1" class="card"></div>
		<div id="card-2" class="card"></div>
		<div id="card-3" class="card"></div>
		<div id="card-4" class="card"></div>
		<div id="card-5" class="card"></div>
	</div>
`;

story_css = `
	div.content {
		display: block;
		/* layout-container + border + margin */
		width: calc((var(--img-width) + 10px) * 6 + 100px + 140px);
		/* margin-top: 110px; */
		margin-top: 50px;
		margin-bottom: 70px;
	}
	
	#layout-container {
		justify-content: space-evenly;
		width: calc( ( var(--img-width) + 10px ) * 6 );
		margin-left: auto;
		margin-right: auto;
	}
`;

