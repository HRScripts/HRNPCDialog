let notDone;

$.post('https://HRNPCDialogue/getThemeColor', JSON.stringify({}), color => {
    $('.npc-dialog-container').css('background', `rgb(${color.r}, ${color.g}, ${color.b})`);
    $('.dialog-option').css('background', `rgb(${color.r}, ${color.g}, ${color.b})`);
}, 'json');

window.addEventListener('message', (event) => {
    const data = event.data;
    if (data.action === 'show') {
        notDone = true;

        hide();
        $('.npc-interaction').show();

        if (data.npcName) {
            $('.npc-role')[0].innerHTML = data.npcName;
        };

        data.questions.reduce(async function(promise, elem, questionIndex) {
            await promise;

            if (questionIndex > 0) {
                await animation($('.npc-dialog-container')[0], 2);
            };

            if (elem.possibleAnswers) {
                elem.possibleAnswers.forEach((answer, answerIndex) => {
                    const currAnswer = $(`<button class="dialog-option" onclick="answerClick(event)">${answer.label}</button>`);
                    currAnswer[0].questionIndex = questionIndex;
                    currAnswer[0].answerIndex = answerIndex;
                    $('.dialog-options').append(currAnswer);
                });
            };

            $.post('https://HRNPCDialogue/getThemeColor', JSON.stringify({}), color => {
                $('.dialog-option').css('background', `rgb(${color.r}, ${color.g}, ${color.b})`);
            }, 'json');

            $('.npc-dialog-container')[0].innerHTML = elem.label;
            await animation($('.npc-dialog-container')[0], 1);

            while (notDone) {
                await new Promise(resolve => setTimeout(resolve, 10));
            };

            notDone = true;
            document.querySelector('.dialog-options').innerHTML = '';

            return Promise.resolve();
        }, Promise.resolve());

        document.body.style.background = 'rgba(15, 15, 0, 0.3)';
    } else if (data.action === 'hide') {
        hide();

        document.body.style.background = 'rgba(0, 0, 0, 0)';
    };
});

window.addEventListener('keydown', (event) => {
    if (event.key == 'Escape' && $('.npc-interaction').css('display') != 'none') {
        document.body.style.background = 'rgba(0, 0, 0, 0)';
        notDone = null;

        hide();
        $.post('https://HRNPCDialogue/hide', JSON.stringify({}), {}, 'json');
    };
});

function answerClick(event) {
    const additional = event.target;
    $.post('https://HRNPCDialogue/answerSelected', JSON.stringify({ questionIndex: additional.questionIndex + 1, answerIndex: additional.answerIndex + 1 }), {}, 'json');

    notDone = null;
};

function hide() {
    document.querySelector('.npc-dialog-container').innerHTML = '';
    document.querySelector('.dialog-options').innerHTML = '';
    document.querySelector('.npc-role').innerHTML = '';
    document.querySelector('.npc-interaction').style.display = 'none';
};

async function animation(element, type) {
    let i = type == 1 ? 0 : element.innerHTML.length;
    const text = element.innerHTML;
    if (type === 1) {
        element.innerHTML = '';
    };

    function typeWriter() {
        if (type === 1 ? (i < text.length) : (i >= 0)) {
            if (type === 1) {
                element.innerHTML += text.charAt(i);
                i++;
            } else {
                element.innerHTML = text.substring(0, i);
                i--;
            };

            setTimeout(typeWriter, 50);
        };
    }

    typeWriter();

    while (type === 1 ? (element.innerHTML != text) : (element.innerHTML.length != 0)) {
        await new Promise(resolve => setTimeout(resolve, 10));
    };
};