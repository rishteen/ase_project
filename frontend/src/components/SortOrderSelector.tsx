import { Button, Menu, MenuButton, MenuItem, MenuList } from "@chakra-ui/react";
import { BsChevronDown } from "react-icons/bs";

interface Props {
  onSelectSortOrder: (sortOrder: string) => void;
  sortOrder: string;
}
const SortSelector = ({ onSelectSortOrder, sortOrder }: Props) => {
  const sortOrders = [
    { value: "", label: "مرتبط" },
    { value: "name", label: "نام" },
    { value: "sortOrder", label: "تاریخ" },
    { value: "views_rate", label: "مشهور" },
    { value: "avg_views", label: "میانگین امتیاز" },
  ];
  const currentSortOrder = sortOrders.find(
    (order) => order.value === sortOrder
  );
  return (
    <Menu placement="bottom-end">
      {" "}
      {/* Adjusted placement here */}
      <MenuButton as={Button} leftIcon={<BsChevronDown />}>
        ترتیب به اساس: {currentSortOrder?.label || "ندارد"}
      </MenuButton>
      <MenuList>
        {sortOrders.map((order) => (
          <MenuItem
            onClick={() => onSelectSortOrder(order.value)}
            key={order.value}
            value={order.value}
          >
            {order.label}
          </MenuItem>
        ))}
      </MenuList>
    </Menu>
  );
};

export default SortSelector;
