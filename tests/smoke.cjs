const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const source = fs.readFileSync('app.js', 'utf8');
const elements = new Map();
const makeElement = () => ({
  value: '', textContent: '', innerHTML: '', disabled: false,
  dataset: {}, style: { left: '42%' },
  classList: { add() {}, remove() {}, contains() { return false; } },
  animate() {}
});
const document = {
  getElementById(id) {
    if (!elements.has(id)) elements.set(id, makeElement());
    return elements.get(id);
  },
  querySelector(selector) {
    if (selector === '[data-gender].active') return { dataset: { gender: 'Male' } };
    return makeElement();
  },
  querySelectorAll(selector) {
    if (selector === '.starting-tree span') return Array.from({ length: 4 }, makeElement);
    if (selector === '.lane-car') return [makeElement(), makeElement()];
    return [];
  },
  addEventListener() {}
};
const storage = new Map();
const localStorage = {
  getItem(key) { return storage.has(key) ? storage.get(key) : null; },
  setItem(key, value) { storage.set(key, value); }
};
let timerId = 0;
const context = {
  document, localStorage, console,
  setTimeout() { return ++timerId; }, clearTimeout() {},
  performance: { now: () => 1000 },
  alert() {}, Math: Object.create(Math)
};
context.globalThis = context;
vm.runInNewContext(source + `
globalThis.__test = {
  startCareer, renderGarage, renderRacing, renderManagement, finishRace, endWeek, go, buyCar, upgrade, payChildSupport, selectEvent, stageRace,
  getState: () => state, getSelectedEvent: () => selectedEvent,
  getSeasonEvent: () => currentSeasonEvent()
};
`, context, { filename: 'app.js' });
const game = context.__test;

document.getElementById('driver-name').value = 'test driver';
game.startCareer();
let state = game.getState();
assert.equal(state.driver, 'Test driver');
assert.deepEqual(Array.from(state.ownedCars), ['Starter Coupe']);
assert.deepEqual(Array.from(state.upgrades), []);
assert.equal(state.season.week, 1);

state.cash = 5000;
game.upgrade();
assert.equal(state.vehiclePower['Starter Coupe'], 225);
game.buyCar('Street Compact');
game.upgrade();
assert.equal(state.carPower, 270);
game.buyCar('Starter Coupe');
assert.equal(state.carPower, 225, 'vehicle tuning should be preserved when switching cars');
game.buyCar('Street Compact');
assert.equal(state.carPower, 270);
game.buyCar('Starter Coupe');

game.renderGarage();
assert.match(document.getElementById('screen').innerHTML, /VEHICLE DEALERSHIP/);
game.renderRacing();
assert.equal(game.getSelectedEvent(), 0);
assert.equal(game.getSeasonEvent().name, 'Street Sprint');

const startingCash = state.cash;
context.__test = game;
vm.runInNewContext('stageRace()', context);
assert.equal(state.cash, startingCash - 150, 'race entry must be charged at staging');
game.go('dashboard');
assert.equal(state.cash, startingCash - 150, 'leaving a staged race must not refund entry');

game.finishRace(true, 12.1, 'WIN — YOU BEAT JAX', 0.2, 12.7);
const firstRoundPoints = state.season.points;
assert.equal(firstRoundPoints, 10);
game.finishRace(false, 12.6, 'RUNNER-UP — JAX TAKES IT', 0.3, 12.4);
assert.equal(state.season.points, firstRoundPoints, 'only one result per round may score');
assert.equal(state.season.rivalPoints.Jax, 0, 'a later race in a scored round must not add rival points');

game.endWeek();
assert.equal(state.season.week, 2);
game.go('racing');
assert.equal(game.getSelectedEvent(), 1);
game.finishRace(false, 2.5, 'RED LIGHT — FALSE START', 1.5, 0);
assert.equal(state.season.rivalPoints.Viper, 20, 'red-light false start awards round points to rival');

game.endWeek();
assert.equal(state.season.week, 3);
game.endWeek();
assert.equal(state.season.week, 4);
assert.equal(state.season.rounds.find(r => r.week === 3).forfeit, true);
assert.equal(state.season.rivalPoints.Jax, 10, 'missed round awards the scheduled rival points');

state.cash = 500;
state.childSupportPaid = 0;
state.childSupportArrears = 0;
state.week = 4;
game.endWeek();
assert.equal(state.cash, 200, 'week-four child support should be deducted after living costs');
assert.equal(state.childSupportPaid, 200);
state.week = 8;
state.cash = 50;
state.season.week = 8;
game.endWeek();
assert.equal(state.childSupportArrears, 200, 'unpaid monthly support should become arrears');
state.cash = 100;
game.payChildSupport();
assert.equal(state.childSupportArrears, 100, 'partial arrears payment should reduce the balance');
assert.equal(state.season.number, 2, 'season should roll over after round eight');
assert.equal(state.season.week, 1);
assert.equal(state.season.points, 0);
assert.equal(state.season.history.length, 1);
state.sponsor = 'NITROLINE PERFORMANCE';
state.sponsorProgress = 2;
game.finishRace(true, 12.0, 'WIN — YOU BEAT JAX', 0.2, 12.6);
assert.equal(state.sponsorCompleted, true, 'completed sponsor contract must not be re-offered');
assert.equal(state.sponsor, null);
game.renderManagement();
assert.match(document.getElementById('screen').innerHTML, /NITROLINE CONTRACT COMPLETED/);
assert.ok(storage.has('dragless-rivalry-career-v1'), 'career save should persist');


state.reputation = 40;
state.cash = 5000;
game.renderRacing();
assert.match(document.getElementById('screen').innerHTML, /MIDNIGHT INVITATIONAL/);
assert.equal(game.selectEvent(3), true, 'the invitational should unlock at 40 reputation');
const roundsBeforeInvite = state.season.rounds.length;
const pointsBeforeInvite = state.season.points;
const cashBeforeInvite = state.cash;
game.stageRace();
assert.equal(state.cash, cashBeforeInvite - 1000, 'invitational entry fee should be charged');
game.finishRace(true, 11.4, 'WIN — YOU BEAT VIPER', 0.2, 11.8);
assert.ok(state.cash >= cashBeforeInvite - 1000 + 4000, 'invitational win should pay its prize, plus any completed weekly bonus');
assert.equal(state.season.rounds.length, roundsBeforeInvite, 'invitational should not consume a championship round');
assert.equal(state.season.points, pointsBeforeInvite, 'invitational should not award championship points');

console.log('PASS: fresh career, garage, race entry, race cancellation, round scoring, false starts, forfeits, season rollover and local save.');
