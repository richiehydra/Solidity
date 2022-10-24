//SPDX-Licensce-Identifer:GPL
pragma solidity >= 0.5.0 < 0.9.0;

contract Ecommerce
{
    struct Product
    {
        string title;
        string desc;
        uint price;
        uint productId;
        address payable seller;
        address buyer;
        bool delivered;
    }
    constructor()
    {
        manager=payable(msg.sender);
    }
    Product [] public products;
    address payable public  manager;
     uint counter=1;
    function registerProduct(string memory _title,string memory _desc,uint _price)public
    {
        require(_price>0,"Price Must be Greater than Zero");
        Product memory tempProduct;
        tempProduct.title=_title;
        tempProduct.desc=_desc;
        tempProduct.price=_price * 10 ** 18;
        tempProduct.productId=counter;
        tempProduct.seller=payable(msg.sender);
        products.push(tempProduct);
        counter++;
    }
   
    function buy(uint _productid)payable public
    {
        require(products[_productid-1].price>=msg.value,"No Sufficient Amount");
        require(products[_productid-1].seller!=msg.sender,"Seller Cant Buy the Product");
        products[_productid-1].buyer=msg.sender;
    }

    function delivery(uint _productid)payable public
    {
     require(products[_productid-1].buyer==msg.sender,"Only Buyer can Call these");
     products[_productid-1].delivered=true;
     products[_productid-1].seller.transfer(products[_productid-1].price);
    }
    function destroyContract()public
    {
     require(msg.sender==manager);
     manager.transfer(address(this).balance);
    }
}
