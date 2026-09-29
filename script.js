const detailsForm = document.getElementById('detailsForm');
const confirmation = document.getElementById('confirmation');
const regNoInput = document.getElementById('secondInput');

regNoInput.addEventListener('input', () => {
  regNoInput.value = regNoInput.value.replace(/\p{L}/gu, '');
});

detailsForm.addEventListener('submit', (event) => {
  event.preventDefault();

  const regNo = regNoInput.value.trim();
  const acceptedRegNos = new Set(['1790-25', '1791-25', '1792-25']);
  window.location.href = acceptedRegNos.has(regNo)
    ? 'class-xii-e.html'
    : 'different-class.html';
});
