# CoachChain

A decentralized professional coaching session tracking and recognition platform for incentivizing personal development on Stacks blockchain.

## Features

- Coaching hour tracking with discipline-based validation
- Professional coach recognition and reward system
- Discipline approval and management system
- Contribution-based recognition point calculation
- Comprehensive coaching program statistics

## Smart Contract Functions

### Public Functions
- `launch-coaching-program` - Initialize coaching tracking program
- `approve-discipline` - Approve discipline for tracking (coordinator only)
- `log-coaching-hours` - Register coaching hours with discipline
- `calculate-recognition-points` - Calculate recognition points (coordinator only)
- `claim-coaching-recognition` - Claim coaching recognition rewards

### Read-Only Functions
- `get-coaching-hours` - Get coach's total hours
- `get-coach-discipline` - Get coach's discipline specialization
- `get-total-coaching-hours` - Get total program hours
- `is-discipline-approved` - Check discipline approval status
- `get-program-stats` - Get comprehensive program statistics

## Disciplines
Life Coaching, Career Coaching, Executive Coaching, Health Coaching, etc.

## Usage

Deploy the contract to create a coaching tracking system where professional coaches can log session hours, earn recognition, and contribute to personal development initiatives.

## License

MIT