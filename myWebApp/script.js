document.addEventListener('DOMContentLoaded', () => {
    const page1 = document.getElementById('page1');
    const page2 = document.getElementById('page2');
    const nextButton = document.getElementById('nextButton');
    const searchButton = document.getElementById('searchButton');
    const backButton = document.getElementById('backButton'); // 戻るボタン
    const userNameInput = document.getElementById('userName');
    const criteriaCheckboxes = document.querySelectorAll('input[name="criteria"]');
    const dynamicInputsContainer = document.getElementById('dynamicInputsContainer');
    const resultsContainer = document.getElementById('resultsContainer');

    // 仮のデータ (読み込むデータ)
    const sampleData = [
        { id: 1, name: "山田 太郎", ageRange: "30代", hobbies: ["釣り", "読書", "キャンプ"], origin: "東京都", affiliation: "開発部" },
        { id: 2, name: "佐藤 花子", ageRange: "20代", hobbies: ["映画鑑賞", "旅行"], origin: "大阪府", affiliation: "営業部" },
        { id: 3, name: "田中 一郎", ageRange: "40代", hobbies: ["ゴルフ", "登山"], origin: "北海道", affiliation: "人事部" },
        { id: 4, name: "鈴木 久美子", ageRange: "30代", hobbies: ["料理", "ヨガ", "釣り"], origin: "福岡県", affiliation: "開発部" },
        { id: 5, name: "高橋 大輔", ageRange: "20代", hobbies: ["サッカー", "ゲーム", "映画鑑賞"], origin: "東京都", affiliation: "マーケティング部" },
        { id: 6, name: "伊藤 さやか", ageRange: "50代", hobbies: ["園芸", "読書"], origin: "京都府", affiliation: "総務部" }
    ];

    let selectedCriteria = []; // page2で使うため、選択された項目を保持

    nextButton.addEventListener('click', () => {
        selectedCriteria = []; // 初期化
        dynamicInputsContainer.innerHTML = ''; // 前回の入力をクリア

        criteriaCheckboxes.forEach(checkbox => {
            if (checkbox.checked) {
                selectedCriteria.push(checkbox.value);
                const div = document.createElement('div');
                const label = document.createElement('label');
                const input = document.createElement('input');

                let labelText = "";
                switch (checkbox.value) {
                    case 'ageRange': labelText = 'あなたの年代:'; break;
                    case 'hobby': labelText = 'あなたの趣味 (複数ある場合はコンマ区切り):'; break;
                    case 'origin': labelText = 'あなたの出身地:'; break;
                    case 'affiliation': labelText = 'あなたの所属:'; break;
                }
                label.textContent = labelText;
                label.htmlFor = `input${checkbox.value}`;

                input.type = 'text';
                input.id = `input${checkbox.value}`;
                input.name = checkbox.value;

                div.appendChild(label);
                div.appendChild(input);
                dynamicInputsContainer.appendChild(div);
            }
        });

        if (selectedCriteria.length > 0 || userNameInput.value.trim() !== "") {
            page1.style.display = 'none';
            page2.style.display = 'block';
        } else {
            alert('名前を入力するか、検索したい情報の種類を1つ以上選択してください。');
        }
    });

    backButton.addEventListener('click', () => {
        page2.style.display = 'none';
        page1.style.display = 'block';
        resultsContainer.innerHTML = ''; // 結果をクリア
    });

    searchButton.addEventListener('click', () => {
        const searchName = userNameInput.value.trim().toLowerCase();
        const searchInputs = {};
        selectedCriteria.forEach(criterion => {
            const inputElement = document.getElementById(`input${criterion}`);
            if (inputElement) {
                searchInputs[criterion] = inputElement.value.trim().toLowerCase();
            }
        });

        const results = sampleData.filter(person => {
            let matches = true;

            // 名前での絞り込み (入力されていれば)
            if (searchName && !person.name.toLowerCase().includes(searchName)) {
                matches = false;
            }

            // 各選択項目での絞り込み
            for (const criterion in searchInputs) {
                const searchValue = searchInputs[criterion];
                if (!searchValue) continue; // その項目が空ならスキップ

                const personValue = person[criterion];

                if (criterion === 'hobbies') { // 趣味は配列なので特別な処理
                    const searchHobbies = searchValue.split(',').map(h => h.trim()).filter(h => h);
                    if (searchHobbies.length > 0 && !searchHobbies.some(sh => personValue.map(ph => ph.toLowerCase()).includes(sh))) {
                        matches = false;
                        break;
                    }
                } else if (personValue && !personValue.toLowerCase().includes(searchValue)) {
                    matches = false;
                    break;
                } else if (!personValue && searchValue) { // データにその項目がない場合
                    matches = false;
                    break;
                }
            }
            return matches;
        });

        displayResults(results);
    });

    function displayResults(results) {
        resultsContainer.innerHTML = ''; // 前回の結果をクリア
        if (results.length === 0) {
            resultsContainer.textContent = '該当する情報は見つかりませんでした。';
            return;
        }

        results.forEach(person => {
            const personDiv = document.createElement('div');
            let details = `<p><strong>名前:</strong> ${person.name}</p>`;
            if (person.ageRange) details += `<p>年代: ${person.ageRange}</p>`;
            if (person.hobbies) details += `<p>趣味: ${person.hobbies.join(', ')}</p>`;
            if (person.origin) details += `<p>出身地: ${person.origin}</p>`;
            if (person.affiliation) details += `<p>所属: ${person.affiliation}</p>`;
            personDiv.innerHTML = details;
            resultsContainer.appendChild(personDiv);
        });
    }
});
