const SimpleStorage =  artifacts.require('simpleStorage.sol');

contract('SimpleStorage' , () => {
    it('should Update Data', async () => {
        const storage = await SimpleStorage.new();
        await storage.updateData(10);
        const data = await storage.readData();
        assert(data.toString() === '10');
    });
});