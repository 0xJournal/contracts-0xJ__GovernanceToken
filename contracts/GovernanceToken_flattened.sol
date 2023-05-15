/*==================================================================================================
     .....                                                                                          
   .:c. .'c;                                                                                        
  'kx.    ,kd.                                                                                      
 .kK;      lXd.                 .:o,'l:.                                                            
 oWk.      ,0X:    ''     '.     'OlcO;                                                             
'0Wo       .kMx.   .l:. .::.     .xlck'                                                             
,KWo       .xMk.    .:l:c,       .xlcx'                                                        .;c. 
.OWd       .kWd.     .o0c        .xlck'                                                         oK: 
 lNO.      ,KK;     .::;l:.      .xlck'                                                         c0: 
 .xK:      oXl     .c;  .:l.     .xlck'     ... .''.   ,c.   'c,  .::..,:..c:...';'   ';...,.   c0: 
  .ox'    ;kc     ,c'     ,l,    .xcck,   'dl.   :xx:  :Kl   '0x. .dK: ....kK,  .o0,  ,;. 'Od.  c0: 
    ,:'..,:'     ,:.       .c,   ,x:l0:  .k0,    .,xK, ;0l   .Ox.  o0,    .xO.   c0:   ...'Ok.  c0: 
      ....                      .od.''.  .dK;    .:k0' ;0l   .Ox.  o0,    .xO.   c0: .ld;..kk.  c0: 
                               .lo.       .cl'  .:dl'  .dd'. ,OO' .x0:    .k0;  .oKl.'kx' 'xk;..oKl 
                             .;c,           ... ..       ... ..'. ..'.    .''.  ..'.  .'.. .'....'. 
                            ...                                                                     
====================================================================================================
* 0xJournal: Defi Payments Platform for Scientific Journaling
* Copyright 2023 0xJournal
* Website: https://www.0xjournal.com/
* SPDX-License-Identifier: MIT
==================================================================================================*/

// File: AccessControl.sol


pragma solidity ^0.8.18;

abstract contract AccessControl {
    mapping(address => bool) internal admins;
    mapping(address => bool) internal burners;
    mapping(address => bool) internal minters;

    constructor() {
        admins[msg.sender] = true;
        burners[msg.sender] = true;
        minters[msg.sender] = true;
    }

    modifier requireAdmin() {
        require(admins[msg.sender], "Not admin.");
        _;
    }
    modifier requireMinter() {
        require(minters[msg.sender], "Not minter.");
        _;
    }
    modifier requireBurner() {
        require(burners[msg.sender], "Not burner.");
        _;
    }

    function setAdmin(address who, bool enable) public requireAdmin {
        admins[who] = enable;
    }

    function setMinter(address who, bool enable) public requireAdmin {
        minters[who] = enable;
    }

    function setBurner(address who, bool enable) public requireAdmin {
        burners[who] = enable;
    }

    function revokeAdmin(address to) public requireAdmin {
        admins[to] = true;
        admins[msg.sender] = false;
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

// File: @openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol


// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;


/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// File: @openzeppelin/contracts/token/ERC20/ERC20.sol


// OpenZeppelin Contracts (last updated v4.8.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;




/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.openzeppelin.com/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, allowance(owner, spender) + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = allowance(owner, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `from` to `to`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
            // Overflow not possible: the sum of all balances is capped by totalSupply, and the sum is preserved by
            // decrementing then incrementing.
            _balances[to] += amount;
        }

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        unchecked {
            // Overflow not possible: balance + amount is at most totalSupply + amount, which is checked above.
            _balances[account] += amount;
        }
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
            // Overflow not possible: amount <= accountBalance <= totalSupply.
            _totalSupply -= amount;
        }

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Updates `owner` s allowance for `spender` based on spent `amount`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

// File: @openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/extensions/ERC20Burnable.sol)

pragma solidity ^0.8.0;



/**
 * @dev Extension of {ERC20} that allows token holders to destroy both their own
 * tokens and those that they have an allowance for, in a way that can be
 * recognized off-chain (via event analysis).
 */
abstract contract ERC20Burnable is Context, ERC20 {
    /**
     * @dev Destroys `amount` tokens from the caller.
     *
     * See {ERC20-_burn}.
     */
    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, deducting from the caller's
     * allowance.
     *
     * See {ERC20-_burn} and {ERC20-allowance}.
     *
     * Requirements:
     *
     * - the caller must have allowance for ``accounts``'s tokens of at least
     * `amount`.
     */
    function burnFrom(address account, uint256 amount) public virtual {
        _spendAllowance(account, _msgSender(), amount);
        _burn(account, amount);
    }
}

// File: GovernanceToken.sol

pragma solidity ^0.8.18;

/**
 * @title GovernanceToken
 * @custom:version 0.5
 * @custom:security-contact support@0xjournal.com
 */
contract GovernanceToken is ERC20, ERC20Burnable, AccessControl {
    uint256 public constant MAX_CAP = 500_000_000; /// Limit of max supply. In units of token (no decimals)
    uint256 public max_supply = 220_000_000; /// Max supply. In units of token (no decimals)
    uint256 public available_mint = 220_000_000; /// Current available number of tokens to be minted until reaching max supply. In units of token (no decimals)

    uint256 public last_tuning_on = 0; /// Keeps the date on the last tuning of inflation parameters

    bool inflation_tuning_active = false;

    uint256 public constant SPAN_MIN = 60 days; /// Min span period is 2 months
    uint256 public constant SPAN_MAX = 365 days; /// Max span period is 1 year
    uint256 public tuning_span = 365 days; /// Span of time necessary to allow adjustments (tuning) of max supply due to inflation. It starts at 354 days.

    uint256 public constant MAX_RATE = 10; /// Max inflation rate is 10%
    uint256 public inflation_rate = 2; /// Inflation rate for max supply (in percentage)

    event InflationRun(bool indexed enabled);
    event InflationTuned(
        uint256 indexed newInflationRatePct,
        uint256 newAdjustmentSpan
    );
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);

    constructor() ERC20("0xJournal", "0xJ") {
        last_tuning_on = block.timestamp;
    }

    /**
     * @notice Allows the admin to run inflation by adjusting the minting parameters.
     * @param enable A boolean value indicating whether to run inflation or not.
     *
     * Requirements :
     * - This function can only be called by the admin.
     * - This function can only be called if there are no available mints left.
     * - This function can only be called if the maximum supply has not yet reached the maximum cap.
     * - This function can only be called if the span for mint parameter redefinition has been reached.
     * - This function can only be called if inflation tuning is already active.
     *
     * Logics :
     * - If `enable` is true, the function will calculate the additional supply based on the inflation rate, and adjust the available mints and maximum supply accordingly. If the sum of the maximum supply and additional supply is greater than or equal to the maximum cap, the available mints and maximum supply will be set to the maximum cap. Otherwise, the available mints will be set to the additional supply, and the maximum supply will be increased by the additional supply. The inflation tuning flag will be set to true.
     * - If `enable` is false, the inflation tuning flag will be set to true (and no change will be made in current inflation params for the current period).
     * - This function will emit an `InflationRun` event.
     * - Throws an error if any of the above conditions are not met.
     */
    function runInflation(bool enable) public requireAdmin {
        require(
            available_mint == 0,
            "There is still available mints to be made before allowing to run inflation."
        );
        require(max_supply <= MAX_CAP, "Max supply already on max limit.");

        uint256 timenow = block.timestamp;
        uint256 duration = timenow - last_tuning_on;
        require(
            duration >= tuning_span,
            "Span for mint params redefinition has not been reached yet."
        );

        // Inflation tuning is already active : this means that runInflation() has been already run once at this period.
        require(
            !inflation_tuning_active,
            "Inflation changes are already active."
        );

        if (enable) {
            uint256 add_supply = (max_supply * inflation_rate) / 100;
            if (max_supply + add_supply >= MAX_CAP) {
                available_mint = MAX_CAP - max_supply;
                max_supply = MAX_CAP;
            } else {
                available_mint = add_supply;
                max_supply += add_supply;
                inflation_tuning_active = true;
            }
        } else {
            inflation_tuning_active = true;
        }

        last_tuning_on = timenow;
        emit InflationRun(enable);
    }

    /**
     * @notice Set the inflation parameters for the next inflation round.
     * @param newRatePct The new inflation rate as a percentage. Must be less than or equal to MAX_RATE.
     * @param newSpan The new span for mint parameter redefinition, in seconds. Must be between SPAN_MIN and SPAN_MAX.
     *
     * Requirements:
     * - The function must be called by an admin.
     * - The inflation parameters must be tunable (i.e. an inflation round must have occurred).
     * - The new span must be between SPAN_MIN and SPAN_MAX.
     * - The new inflation rate must be less than or equal to MAX_RATE.
     *
     * Logics :
     * - Updates the inflation parameters
     * - Emits an {InflationTuned} event with the new inflation rate and span.
     */
    function tuneInflation(uint256 newRatePct, uint256 newSpan)
        public
        requireAdmin
    {
        require(
            inflation_tuning_active,
            "Changes on inflation are only allowed after an inflation round."
        );
        require(
            newSpan >= SPAN_MIN && newSpan <= SPAN_MAX,
            "Span limits exceeds."
        );
        require(newRatePct <= MAX_RATE, "Max inflation rate exceeded.");

        inflation_rate = newRatePct;
        tuning_span = newSpan;
        emit InflationTuned(inflation_rate, tuning_span);

        inflation_tuning_active = false;
    }

    /**
     * @notice Mints new tokens and assigns them to the specified address.
     * @param to The address that will receive the minted tokens.
     * @param amount The amount of tokens to mint, in units of token (no decimals).
     *
     * Requirements:
     * - The caller must be a minter of the contract.
     * - The address `to` must not be the null address.
     * - The `amount` must be greater than 0.
     * - There must be available mintable tokens to mint.
     * - The `amount` being minted must not exceed the available mintable tokens.
     *
     * Effects:
     * - Increases the total supply of tokens by `amount` multiplied by 10^decimals.
     * - Decreases the available mintable tokens by `amount`.
     * - Emits a {Mint} event indicating the address that received the minted tokens and the amount minted.
     */
    function mint(
        address to,
        uint256 amount /*in units of token (no decimals*/
    ) public requireMinter {
        require(to != address(0), "Null address.");
        require(amount > 0, "Amount not positive.");
        require(available_mint > 0, "Not available mintable tokens.");
        require(
            amount <= available_mint,
            "Amount surpasses available mintable"
        );
        assert(available_mint > available_mint - amount);

        _mint(to, amount * 10**decimals());
        available_mint -= amount;

        emit Mint(to, amount);
    }

    /**
     * @notice Burns a specific amount of tokens from the caller's account, reducing the total supply.
     * @param amount uint256 The amount of tokens to be burned, specified in units of token (no decimals).
     *
     * Requirements:
     * - amount shall be non-zero positive.
     * - The caller must have enough tokens to burn this amount.
     *
     * Logics :
     * - amount of tokens will be removed from the caller's account.
     * - max_supply will be reduced by amount.
     * Emits an {Burn} event indicating the amount burned and the burner address.
     */
    function burn(uint256 amount) public override requireBurner {
        require(amount > 0, "Burn number shall be non-zero positive.");
        require(
            balanceOf(msg.sender) >= amount,
            "Not enough tokens to burn this amount."
        );

        super.burn(amount);

        max_supply -= amount;

        emit Burn(msg.sender, amount);
    }
}
