const fs = require('fs');
const readline = require('readline');

// 1. Справочники
const DICTIONARIES = {
    bad_things: [
        {id: 1, name: 'Дорогая еда в кабаке'},
        {id: 2, name: 'Долгое ожидание в мертвяке (при массовых смертях)'},
        {id: 3, name: 'Детям не хватило контента'},
        {id: 4, name: 'Плохо игралась политика'},
        {id: 5, name: 'Не было денег'},
        {id: 6, name: 'Непонятно у кого брать квесты'},
        {id: 7, name: 'Не дошли стартовые деньги'},
        {id: 8, name: 'Квкстовые предметы не доходили до тех до кого надо'}
    ],
    improve_things: [
        {id: 1, name: 'Азартные игры' },
        {id: 2, name: 'Арена для боёв один на один'},
        {id: 3, name: 'Построение в начале игры с повтором основных правил'},
        {id: 4, name: 'Больше квестов чисто для заработка, без привязки к фракции'},
        {id: 5, name: 'Игровая возможность "закрыть" здание на замок (напр. чтобы живая стража сходила пообедать)'},
        {id: 6, name: 'Проработка законов, возможно суд'},
        {id: 7, name: 'Облегчить поиск квестодателей'},
        {id: 8, name: '"Серийный" (сквозной, связанный) сюжет на несколько игр'}
    ]
};

// Подготовка словарей: сортируем от длинных фраз к коротким, чтобы захватывать более специфичные совпадения первыми
Object.keys(DICTIONARIES).forEach(key => {
    DICTIONARIES[key].sort((a, b) => b.name.length - a.name.length);
});

const normalize = (str) => str.trim().toLowerCase();

function processLine(jsonLine) {
    if (!jsonLine.trim()) return null;

    try {
        const data = JSON.parse(jsonLine);
        
        ['bad_things', 'improve_things'].forEach(field => {
            const dictionary = DICTIONARIES[field];
            if (!data[field] || !dictionary) return;

            let currentText = data[field] + ',';
            const foundIds = [];
            
            // Проходим по каждому стандартному ответу
            dictionary.forEach(item => {
                const lowerName = normalize(item.name);
                const lowerText = normalize(currentText);

                // Ищем вхождение фразы в тексте пользователя
                if (lowerText.includes(lowerName)) {
                    foundIds.push(item.id);
                    
                    // Удаляем найденную фразу из текста. 
                    // Используем replace с регуляркой, чтобы удалить именно эту подстроку (case-insensitive)
                    // Экранируем спецсимволы для regex, если они есть в названии
                    const escapedName = item.name.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
                    const regex = new RegExp(escapedName, 'gi'); // g - global, i - case insensitive
                    
                    currentText = currentText.replace(regex, '');
                }
            });

            // Чистим оставшийся текст от лишних запятых и пробелов, которые остались после вырезания
            // 1. Заменяем множественные запятые/пробелы на одну запятую
            let cleanCustom = currentText
                .replace(/(, )+/g, ', ')
                .trim()
                // 2. Убираем запятые в начале и конце
                .replace(/^,|,$/g, '').trim();
            // 3. Убираем пустые элементы, если остались только разделители
            if (!cleanCustom) cleanCustom = null;

            // Сохраняем результаты
            const idsFieldName = `default_${field.replace('_things', '')}_ids`;
            data[idsFieldName] = foundIds.length > 0 ? foundIds.sort() : null;
            data[field] = cleanCustom;
        });

        return JSON.stringify(data);
    } catch (e) {
        console.error("Ошибка:", e.message);
        return null;
    }
}

async function run() {
    const inputFile = 'b_extracted_raw.json';
    const outputFile = 'd_default_excluded.jsonl';
    const outputFile2 = 'e_hand_edit.jsonl';

    console.log(`Обработка ${inputFile}...`);
    const fileStream = fs.createReadStream(inputFile);
    const rl = readline.createInterface({ input: fileStream, crlfDelay: Infinity });
    const writeStream = fs.createWriteStream(outputFile);
    const writeStream2 = fs.createWriteStream(outputFile2);

    for await (const line of rl) {
        const processedLine = processLine(line);
        if (processedLine) writeStream.write(processedLine + '\n');
        if (processedLine) writeStream2.write(processedLine + '\n');
    }

    writeStream.end();
    writeStream2.end();
    console.log(`Готово! Файл: ${outputFile}`);
}

run();