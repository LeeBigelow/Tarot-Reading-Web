const layoutStyle = document.getElementById('layout-css');
const layoutHtml = document.getElementById('layout-html');

// global vars
let selectedDeck;
let selectedLayout;
let selectedCardCodes;
let numCards;
let cardNum;
let deckTitle;
let deckImage;

const layouts = [
	'Clock',
	'Cross',
	'Diamond',
	'Story',
	'Triangle',
];

const layoutList = document.getElementById('layout-list');
layouts.forEach(layout => {
	const layoutDiv = document.createElement('div');
	layoutDiv.addEventListener('click', function () {
		layoutInit(layout.toLowerCase(),selectedDeck);
	});
	layoutDiv.innerHTML = layout;
	layoutList.appendChild(layoutDiv);
});

// EMBEDDED IGNORE START
const imageDir = 'resources/images/';

const cardDecks = [
	// DECKS START
	'1709_Pierre_Madenié_(Ben-Dov)',
	'1709_Pierre_Madenié_(McElroy)',
	'1760_Nicolas_Conver_(Ben-Dov)',
	'1760_Nicolas_Conver_(McElroy)',
	'1789_Etteilla_Livre_de_Thot_(Etteila)',
	'1835_Gumppenberg_Dellarocca_(Ben-Dov)',
	'1835_Gumppenberg_Dellarocca_(McElroy)',
	'1880_Avondo_Dellarocca_(Ben-Dov)',
	'1880_Avondo_Dellarocca_(McElroy)',
	'1909_Rider-Waite-Smith_(McElroy)',
	'1909_Rider-Waite-Smith_(Waite)',
	'2010_Yoav_Ben-Dov_(Ben-Dov)',
	'2010_Yoav_Ben-Dov_(McElroy)',
	// DECKS END
];

// Add decks to dropdown list
const deckList = document.getElementById('deck-list');
cardDecks.forEach(deckDir => {
	const deckDiv = document.createElement('div');
	deckDiv.addEventListener('click', function () {
		changeDeck(deckDir);
	});
	deckDiv.innerHTML = deckDir.replace(/_/g,' ');
	deckList.appendChild(deckDiv);
});

// EMBEDDED IGNORE END

function changeDeck(deck) {
	selectedDeck = deck;
	deckTitle.innerHTML = selectedDeck.replace(/_/g,' ');

	deckImage.src = imageDir + selectedDeck + '/XBA.webp';
	deckImage.alt = deckImage.src;
}

const cardCodes = [
	'B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B07',
	'B08', 'B09', 'B10', 'B11', 'B12', 'B13', 'B14',
	'C01', 'C02', 'C03', 'C04', 'C05', 'C06', 'C07',
	'C08', 'C09', 'C10', 'C11', 'C12', 'C13', 'C14',
	'D01', 'D02', 'D03', 'D04', 'D05', 'D06', 'D07',
	'D08', 'D09', 'D10', 'D11', 'D12', 'D13', 'D14',
	'S01', 'S02', 'S03', 'S04', 'S05', 'S06', 'S07',
	'S08', 'S09', 'S10', 'S11', 'S12', 'S13', 'S14',
	'T00', 'T01', 'T02', 'T03', 'T04', 'T05', 'T06',
	'T07', 'T08', 'T09', 'T10', 'T11', 'T12', 'T13',
	'T14', 'T15', 'T16', 'T17', 'T18', 'T19', 'T20',
	'T21'
];

function shuffleArray(array) {
	for (let i = array.length - 1; i > 0; i--) {
		const j = Math.floor(Math.random() * (i + 1));
		[array[i], array[j]] = [array[j], array[i]];
	};
};

function getRandomCards(count) {
	shuffleArray(cardCodes);
	return cardCodes.slice(0, count);
};

// Animate the card deal
// Shift card from final position to deck then animate back
function dealCard(cardDiv) {
	const deckRect = deckImage.getBoundingClientRect();
	const cardRect = cardDiv.getBoundingClientRect();
	let xdiff = deckRect.left - cardRect.left;
	let ydiff = deckRect.top - cardRect.top;
	cardDiv.animate([{
		transformOrigin: 'top left',
		transform: `translate(${xdiff}px, ${ydiff}px)`
	}, {
		transformOrigin: 'left center',
		transform: 'rotateY(60deg)'
	}, {
		transformOrigin: 'top left',
		transform: 'none'
	}], {
		duration: 600,
	});
};

function showCard() {
	if (cardNum == numCards+2) { 
		layoutInit(selectedLayout,selectedDeck);
		return
	};
	if (cardNum == numCards+1) {
		deckImage.style.opacity = "0.6";
		cardNum++;
		return;
	};
	let cardCode = selectedCardCodes[cardNum-1];
	const cardDiv = document.getElementById('card-'+cardNum);

	const cardInnerDiv = document.createElement('div');
	cardInnerDiv.classList.add('card-inner');
	cardInnerDiv.addEventListener('click', function () {
		cardInnerDiv.classList.toggle('is-flipped');
	});

	const cardFrontDiv = document.createElement('div');
	cardFrontDiv.classList.add('card-front');

	const cardBackDiv = document.createElement('div');
	cardBackDiv.classList.add('card-back');

	const imageFront = document.createElement('img');
	const imageBack = document.createElement('img');
	imageFront.src = imageDir + selectedDeck + '/' + cardCode + '.webp';
	imageFront.alt = imageFront.src;
	imageBack.src = imageFront.src;
	imageBack.alt = imageFront.src;
	if (Math.random() < 0.5) {
		imageFront.style.transform = "rotate(180deg)";
	}
	cardFrontDiv.appendChild(imageFront);
	cardBackDiv.appendChild(imageBack);

	switch (true) {
		// MEANINGS START
		case selectedDeck.includes('(McElroy)'):
			// McElroy meanings with Waite deck switch Justice and Strength cards
			if ( !(selectedDeck.includes('Waite')) 
				|| (cardCode != 'T08' && cardCode != 'T11') ) {
				cardBackDiv.innerHTML += mcelroyMeanings[cardCode];
			} else if (cardCode == 'T08') {
				// only here if Waite and T08
				cardCode='T11';
				cardBackDiv.innerHTML += mcelroyMeanings[cardCode].replace('11','8');
			} else if (cardCode == 'T11') {
				// only here if Waite and T11
				cardCode='T08';
				cardBackDiv.innerHTML += mcelroyMeanings[cardCode].replace('8','11');
			} else {
				// sanity check
				console.log(selectedDeck+" "+cardCode);
			}
			cardBackDiv.innerHTML += '<p class="author">-- Mark McElroy</p>';
			break;
		case selectedDeck.includes('(Ben-Dov)'):
			cardBackDiv.innerHTML += bendovMeanings[cardCode];
			cardBackDiv.innerHTML += '<p class="author">-- Yoav Ben-Dov</p>';
			break;
		case selectedDeck.includes('(Waite)'):
			cardBackDiv.innerHTML += waiteMeanings[cardCode];
			cardBackDiv.innerHTML += '<p class="author">-- A. E. Waite</p>';
			break;
		case selectedDeck.includes('(Etteilla)'):
			cardBackDiv.innerHTML += etteillaMeanings[cardCode];
			cardBackDiv.innerHTML += '<p class="author">-- Etteilla</p>';
			break;
		default:
			cardBackDiv.innerHTML += mcelroyMeanings[cardCode];
			cardBackDiv.innerHTML += '<p class="author">-- Mark McElroy</p>';
			break;
		// MEANINGS END
	}

	cardInnerDiv.appendChild(cardFrontDiv);
	cardInnerDiv.appendChild(cardBackDiv);
	cardDiv.appendChild(cardInnerDiv);
	dealCard(cardDiv);
	cardNum++;
};

function layoutInit(layout, deck) {
	selectedDeck = deck;
	selectedLayout = layout;
	document.title = window[selectedLayout+'_title'];
	layoutStyle.innerHTML = window[selectedLayout+'_css'];
	layoutHtml.innerHTML = window[selectedLayout+'_html'];

	deckTitle = document.getElementById('deck-title');
	deckImage = document.getElementById('deck-image');
	cardNum = 1;
	numCards = Number(document.title.split(' - ')[2]);

	selectedCardCodes = getRandomCards(numCards);
	deckImage.addEventListener('click', function () { showCard(); } );
	changeDeck(deck)
};

layoutInit("story", "1760_Nicolas_Conver_(Ben-Dov)");
