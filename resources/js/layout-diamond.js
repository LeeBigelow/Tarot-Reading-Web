diamond_title = 'Tarot Reading Web - Diamond - 9';

diamond_html = `
	<h1>Diamond</h1>
	<div id="layout-container">
		<div class="card card-deck">
			<img id="deck-image"/>
			<div id="deck-title"></div>
		</div>
		<div id="row-1" class="row">
			<div id="card-6" class="card"></div>
		</div>
		<div id="row-2" class="row">
			<div id="card-4" class="card"></div>
			<div id="card-5" class="card"></div>
		</div>
		<div id="row-3" class="row">
			<div id="card-2" class="card"></div>
			<div id="card-1" class="card"></div>
			<div id="card-3" class="card"></div>
		</div>
		<div id="row-4" class="row">
			<div id="card-7" class="card"></div>
			<div id="card-8" class="card"></div>
		</div>
		<div id="row-5" class="row">
			<div id="card-9" class="card"></div>
		</div>
	</div>
`;

diamond_css = `
	div.content {
		display: block;
		width: calc((var(--img-width) + 10px ) * 4 + 100px + 140px);
		margin-top: 10px;
		margin-bottom: 70px;
	}
	
	#layout-container {
		position: relative;
		display: flex;
		flex-direction: column;
		justify-content: center;
		width: calc( var(--img-width) * 4 + 100px);
		height: calc( var(--img-height) * 5 + 100px );
		margin-left: auto;
		margin-right: auto;
		gap: 10px;
	}
	
	h1 {
		width: calc( var(--img-width) * 5 + 50px + 100px);
	}
	
	.row {
		display: flex;
		flex-direction: row;
		justify-content: center;
		gap: 10px;
	}
	
	.card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg);
	}
	
	/* position deck */
	.card-deck {
		position: absolute;
		top: 20px;
		left: 20px;
		margin: 0px;
	}
	
	.card {
		margin: 0;
	}
`;

