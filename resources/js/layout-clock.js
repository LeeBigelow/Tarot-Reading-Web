clock_title = 'Tarot Reading Web - Clock - 9';

clock_html = `
	<h1>Clock</h1>
	<div id="layout-container">
		<div class="card card-deck">
			<img id="deck-image"/>
			<div id="deck-title"></div>
		</div>
		<div id="col-1" class="column">
			<div id="card-8" class="card"></div>
			<div id="card-7" class="card"></div>
			<div id="card-6" class="card"></div>
		</div>
		<div id="col-2" class="column">
			<div id="card-9" class="card"></div>
			<div id="card-1" class="card"></div>
			<div id="card-5" class="card"></div>
		</div>
		<div id="col-3" class="column">
			<div id="card-2" class="card"></div>
			<div id="card-3" class="card"></div>
			<div id="card-4" class="card"></div>
		</div>
	</div>
`;

clock_css = `
	div.content {
		display: block;
		width: calc((var(--img-width) + 10px ) * 6 + 100px + 140px);
		margin-top: 10px;
		margin-bottom: 70px;
	}
	
	#layout-container {
		position: relative;
		justify-content: right;
		width: calc( var(--img-width) * 5 + 250px);
		margin-left: auto;
		margin-right: auto;
		padding-top: 50px;
		padding-bottom: 50px;
	}
	
	h1 {
		width: calc( var(--img-width) * 5 + 50px + 100px);
	}
	
	.column {
		display: flex;
		flex-direction: column;
		justify-content: center;
		align-items: center;
	}
	
	#col-3 {
		margin-right: 150px;
	}
	
	#col-2 {
		justify-content: space-between;
		width: calc( var(--img-width) );
		margin: 0 -35px;
		gap: 80px;
	}
	
	#col-1,
	#col-3 {
		width: hypot( var(--img-height), var(--img-width) );
	}
	
	#col-1 .card,
	#col-3 .card {
		margin: -30px;
	}
	
	.card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg);
	}
	
	#card-2 .card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg) rotate(45deg);
	}
	
	#card-3 .card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg) rotate(90deg);
	}
	#card-4 .card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg) rotate(135deg);
	}
	#card-6 .card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg) rotate(-135deg);
	}
	#card-7 .card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg) rotate(-90deg);
	}
	#card-8 .card-inner.is-flipped {
		transform: scale(180%) rotateY(180deg) rotate(-45deg);
	}
	
	/* position deck */
	.card-deck {
		position: absolute;
		top: 20px;
		left: 20px;
		margin: 0px;
	}
	
	#card-2 {
		transform: rotate(45deg);
	}
	#card-3 {
		transform: rotate(90deg) translate( 0, calc(-1*var(--img-height)/3 - 5px));
	}
	#card-4 {
		transform: rotate(135deg);
	}
	#card-6 {
		transform: rotate(-135deg);
	}
	#card-7 {
		transform: rotate(-90deg) translate(0, calc(-1*var(--img-height)/3 - 5px));
	}
	#card-8 {
		transform: rotate(-45deg);
	}
`;

