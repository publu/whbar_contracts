const hbar_filter = artifacts.require("hbar_filter");
const accounts = require("./util/accounts");
const {
    expectRevert
} = require("@openzeppelin/test-helpers");

contract('hbar_filter', () => {
    let contract;

    beforeEach( async () => {
        contract = await hbar_filter.new({from: accounts.public.admin});
    });

    it('Changing minimum affects deposits', async () => {
        await contract.deposit({from: accounts.public.alice, value: 1000});
        await contract.changeMin(2000, {from: accounts.public.admin});
        await expectRevert(contract.deposit({from: accounts.public.alice, value: 1000}), 'revert');
    });

    it('Changing admin affects deposits', async () => {
        let balanceOld, balanceNew;
        await contract.changeAdmin(accounts.public.alice, {from: accounts.public.admin});
        await web3.eth.getBalance(accounts.public.alice, (err, balance) => { balanceOld = web3.utils.toBN(balance); });
        await contract.deposit({from: accounts.public.bob, value: 1000});
        await web3.eth.getBalance(accounts.public.alice, (err, balance) => { balanceNew = web3.utils.toBN(balance); });
        assert.equal(balanceNew.sub(balanceOld).toNumber(), 1000, "Added 1000 wei to new admin's account");
    });

    it('Only admin may make changes', async () => {
        await expectRevert(contract.changeAdmin(accounts.public.alice, {from: accounts.public.alice}), 'revert');
        await expectRevert(contract.changeMin(100, {from: accounts.public.alice}), 'revert');
    });
});
