const whbar = artifacts.require("whbar");
const accounts = require("./util/accounts");
const {
    expectRevert
} = require("@openzeppelin/test-helpers");

contract('whbar', () => {
    let contract;

    beforeEach( async () => {
        contract = await whbar.new(accounts.public.validator, accounts.public.admin);
        await contract.mint(100, accounts.public.bob, {from: accounts.public.validator});
    });

    it('Update validator', async () => {
        await contract.updateValidator(accounts.public.alice, {from: accounts.public.admin}); // Alice is the new validator

        await expectRevert(contract.mint(50, accounts.public.alice, {from: accounts.public.validator}), 'revert'); // Old validator can no longer mint
        balanceOld = await contract.balanceOf.call(accounts.public.bob);
        await contract.mint(50, accounts.public.bob, {from: accounts.public.alice}); // Now Alice can mint
        balanceNew = await contract.balanceOf.call(accounts.public.bob);
        assert.equal(balanceNew.sub(balanceOld).toNumber(), 5000000000, "5000000000 whbar minted by new validator");
    });

    it('Update admin', async () => {
        await contract.updateAdmin(accounts.public.alice, {from: accounts.public.admin}); // Alice is the new admin
        await expectRevert(contract.updateAdmin(accounts.public.admin, {from: accounts.public.admin}), 'revert'); // Old Admin loses privileges

        await contract.updateValidator(accounts.public.bob, {from: accounts.public.alice}); // Alice can set a new validator
    });

    it('Only admin may make changes', async () => {
        await expectRevert(contract.updateValidator(accounts.public.alice, {from: accounts.public.alice}), 'revert');
        await expectRevert(contract.updateAdmin(accounts.public.alice, {from: accounts.public.alice}), 'revert');
    });

    it('Burn whbar', async () => {
        balanceOld = await contract.balanceOf.call(accounts.public.bob);
        await contract.methods['burn(uint256,address)'](100, accounts.public.alice, {from: accounts.public.bob});
        balanceNew = await contract.balanceOf.call(accounts.public.bob);
        assert.equal(balanceNew.sub(balanceOld).toNumber(), -100, "100 Tokens burned");
    });

    it('Burn whbar from allowance', async () => {
        balanceOld = await contract.balanceOf.call(accounts.public.bob);
        await contract.approve(accounts.public.alice, 100, {from: accounts.public.bob});
        await contract.methods['burnFrom(uint256,address,address)'](100, accounts.public.bob, accounts.public.alice, {from: accounts.public.alice});
        balanceNew = await contract.balanceOf.call(accounts.public.bob);
        assert.equal(balanceNew.sub(balanceOld).toNumber(), -100, "100 Tokens burned from allowance");
    });

    it('Mint whbar', async () => {
        await contract.mint(50, accounts.public.alice, {from: accounts.public.validator});
        bal = await contract.balanceOf.call(accounts.public.alice);
        assert.equal(bal.toNumber(), 5000000000, "Alice wasn't minted 5000000000 whbar");
    });

    it('Can\'t mint when not validator', async () => {
        await expectRevert(contract.mint(50, accounts.public.alice, {from: accounts.public.bob}), 'revert'); // Can't mint if caller isn't the validator
    });
});
